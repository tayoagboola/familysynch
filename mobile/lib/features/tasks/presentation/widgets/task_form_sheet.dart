import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme.dart';
import '../../../../../shared/providers/household_providers.dart';
import '../../../calendar/presentation/widgets/member_chip.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_providers.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _dueDate;
  String? _assignedTo;
  int _points = 0;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _dueDate = t.dueDate?.toLocal();
      _assignedTo = t.assignedTo;
      _points = t.points;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    bool ok;
    if (_isEditing) {
      ok = await ref.read(taskActionsProvider.notifier).updateTask(
            id: widget.task!.id,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            dueDate: _dueDate,
            assignedTo: _assignedTo,
            points: _points,
          );
    } else {
      ok = await ref.read(taskActionsProvider.notifier).createTask(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            dueDate: _dueDate,
            assignedTo: _assignedTo,
            points: _points,
          );
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not ${_isEditing ? 'update' : 'create'} task.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = ref.watch(householdMembersProvider).valueOrNull ?? [];
    final isLoading = ref.watch(taskActionsProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Form(
          key: _formKey,
          child: Column(children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.sm, 0),
              child: Row(children: [
                Text(
                  _isEditing ? 'Edit task' : 'New task',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                ),
              ]),
            ),
            const Divider(),

            // Scrollable body
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Title
                  TextFormField(
                    controller: _titleCtrl,
                    autofocus: !_isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.titleMedium,
                    decoration: const InputDecoration(
                      hintText: 'Task title',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),

                  // Due date
                  _SectionRow(
                    icon: Icons.calendar_today_outlined,
                    label: _dueDate != null
                        ? DateFormat('EEE, MMM d').format(_dueDate!)
                        : 'Add due date',
                    trailing: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => _dueDate = null),
                          )
                        : null,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 1)),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setState(() => _dueDate = d);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Assign to
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.person_outline, size: 20),
                          const SizedBox(width: AppSpacing.md),
                          Text('Assign to',
                              style: theme.textTheme.bodyLarge),
                        ]),
                        const SizedBox(height: AppSpacing.sm),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            _UnassignedChip(
                              isSelected: _assignedTo == null,
                              onTap: () =>
                                  setState(() => _assignedTo = null),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            ...members.map((m) => Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.xs),
                                  child: MemberChip(
                                    member: m,
                                    isSelected: _assignedTo == m.userId,
                                    onTap: () => setState(
                                        () => _assignedTo = m.userId),
                                  ),
                                )),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Points
                  _SectionCard(
                    child: Row(children: [
                      const Icon(Icons.star_outline, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text('Points', style: theme.textTheme.bodyLarge),
                      const Spacer(),
                      _PointsStepper(
                        value: _points,
                        onChanged: (v) => setState(() => _points = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  _SectionCard(
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
                            textCapitalization:
                                TextCapitalization.sentences,
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
          ]),
        ),
      ),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyLarge),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
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

class _UnassignedChip extends StatelessWidget {
  const _UnassignedChip({required this.isSelected, required this.onTap});
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
          Text('Anyone',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? theme.colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              )),
          if (isSelected) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.check,
                size: 14, color: theme.colorScheme.primary),
          ],
        ]),
      ),
    );
  }
}

class _PointsStepper extends StatelessWidget {
  const _PointsStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: value > 0 ? () => onChanged(value - 1) : null,
        iconSize: 20,
      ),
      SizedBox(
        width: 32,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: value < 99 ? () => onChanged(value + 1) : null,
        iconSize: 20,
      ),
    ]);
  }
}
