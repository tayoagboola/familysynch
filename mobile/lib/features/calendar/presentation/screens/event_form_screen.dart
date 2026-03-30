import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../controllers/calendar_providers.dart';
import '../widgets/member_chip.dart';

const _kEventColors = [
  Color(0xFF2196F3),
  Color(0xFFE91E63),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFF9C27B0),
  Color(0xFFFF5722),
  Color(0xFF00BCD4),
  Color(0xFF607D8B),
];

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.event});
  final CalendarEvent? event;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  String? _assignedTo;
  late Color _color;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description ?? '';
      _startDate = e.startTime.toLocal();
      _startTime = TimeOfDay.fromDateTime(e.startTime.toLocal());
      _endDate = (e.endTime ?? e.startTime).toLocal();
      _endTime =
          TimeOfDay.fromDateTime((e.endTime ?? e.startTime).toLocal());
      _isAllDay = e.isAllDay;
      _assignedTo = e.assignedTo;
      _color = e.color != null
          ? HexColor.fromHex(e.color!)
          : _kEventColors.first;
    } else {
      final now = DateTime.now();
      _startDate = now;
      _startTime = TimeOfDay(
          hour: now.minute > 30 ? (now.hour + 1) % 24 : now.hour,
          minute: 0);
      _endDate = now;
      _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: 0);
      _color = _kEventColors.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onAssigneeChanged(String? userId, List<HouseholdMember> members) {
    setState(() {
      _assignedTo = userId;
      if (userId != null) {
        final m = members.firstWhereOrNull((m) => m.userId == userId);
        if (m != null) _color = HexColor.fromHex(m.color);
      } else {
        _color = _kEventColors.first;
      }
    });
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final startDt = _isAllDay
        ? DateTime(_startDate.year, _startDate.month, _startDate.day)
        : _combine(_startDate, _startTime);
    final endDt = _isAllDay ? null : _combine(_endDate, _endTime);

    if (!_isAllDay && endDt != null && endDt.isBefore(startDt)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('End time must be after start time.')));
      return;
    }

    final colorHex = _color.toHex();
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    bool ok;

    if (_isEditing) {
      ok = await ref.read(calendarActionsProvider.notifier).updateEvent(
            id: widget.event!.id,
            title: _titleCtrl.text.trim(),
            description: desc,
            startTime: startDt,
            endTime: endDt,
            isAllDay: _isAllDay,
            assignedTo: _assignedTo,
            color: colorHex,
          );
    } else {
      ok = await ref.read(calendarActionsProvider.notifier).createEvent(
            title: _titleCtrl.text.trim(),
            description: desc,
            startTime: startDt,
            endTime: endDt,
            isAllDay: _isAllDay,
            assignedTo: _assignedTo,
            color: colorHex,
          );
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not ${_isEditing ? 'update' : 'create'} event.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = ref.watch(householdMembersProvider).valueOrNull ?? [];
    final isLoading = ref.watch(calendarActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit event' : 'New event'),
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _save,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.titleLarge,
              decoration: const InputDecoration(
                hintText: 'Event title',
                border: InputBorder.none,
                filled: false,
                contentPadding:
                    EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required'
                  : null,
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            _Section(
              child: Row(children: [
                const Icon(Icons.wb_sunny_outlined, size: 20),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: Text('All day')),
                Switch(
                    value: _isAllDay,
                    onChanged: (v) => setState(() => _isAllDay = v)),
              ]),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Section(
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.schedule_outlined, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  _Chip(
                    label: DateFormat('EEE, MMM d').format(_startDate),
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (d != null) setState(() => _startDate = d);
                    },
                  ),
                  if (!_isAllDay) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _Chip(
                      label: _startTime.format(context),
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: _startTime);
                        if (t != null) setState(() => _startTime = t);
                      },
                    ),
                  ],
                ]),
                if (!_isAllDay) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    const SizedBox(width: 36),
                    _Chip(
                      label: DateFormat('EEE, MMM d').format(_endDate),
                      onTap: () async {
                        final d = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime(2030));
                        if (d != null) setState(() => _endDate = d);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _Chip(
                      label: _endTime.format(context),
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: _endTime);
                        if (t != null) setState(() => _endTime = t);
                      },
                    ),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Text('Assign to', style: theme.textTheme.bodyLarge),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _EveryoneChip(
                        isSelected: _assignedTo == null,
                        onTap: () => _onAssigneeChanged(null, members),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ...members.map((m) => Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.xs),
                            child: MemberChip(
                              member: m,
                              isSelected: _assignedTo == m.userId,
                              onTap: () =>
                                  _onAssigneeChanged(m.userId, members),
                            ),
                          )),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.circle, size: 20, color: _color),
                    const SizedBox(width: AppSpacing.md),
                    Text('Color', style: theme.textTheme.bodyLarge),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: _kEventColors
                        .map((c) => _ColorSwatch(
                              color: c,
                              isSelected: _color == c,
                              onTap: () => setState(() => _color = c),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Section(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Icon(Icons.notes_outlined, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _descCtrl,
                      maxLines: null,
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Add a note (optional)',
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: child,
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text(label),
        onPressed: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      );
}

class _EveryoneChip extends StatelessWidget {
  const _EveryoneChip({required this.isSelected, required this.onTap});
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.groups_outlined,
              size: 18,
              color: isSelected ? theme.colorScheme.primary : null),
          const SizedBox(width: AppSpacing.xs),
          Text('Everyone',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? theme.colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              )),
          if (isSelected) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
          ],
        ]),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(
      {required this.color,
      required this.isSelected,
      required this.onTap});
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside)
                : null,
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      );
}

extension _FirstOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
