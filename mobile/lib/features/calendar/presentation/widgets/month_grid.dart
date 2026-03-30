import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/calendar_event.dart';
import '../controllers/calendar_providers.dart';
import '../providers/calendar_extra_providers.dart';
import 'event_color_utils.dart';

class MonthGrid extends ConsumerStatefulWidget {
  const MonthGrid({super.key});

  @override
  ConsumerState<MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends ConsumerState<MonthGrid> {
  DateTime? _previousMonth;
  bool _goingForward = true;

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(calendarMonthProvider);
    final eventsMap = ref.watch(monthEventsMapProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    if (_previousMonth != null && _previousMonth != month) {
      _goingForward = month.isAfter(_previousMonth!);
    }
    _previousMonth = month;

    return Column(
      children: [
        // Day of week headers
        _DowHeaders(),
        const SizedBox(height: 4),
        // Month grid with slide animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) {
            final offset = _goingForward
                ? const Offset(1.0, 0)
                : const Offset(-1.0, 0);
            final slideIn = Tween<Offset>(
              begin: offset,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slideIn, child: child),
            );
          },
          child: _Grid(
            key: ValueKey('${month.year}-${month.month}'),
            month: month,
            eventsMap: eventsMap,
            selectedDay: selectedDay,
          ),
        ),
      ],
    );
  }
}

class _DowHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.screenPadding),
      child: Row(
        children: List.generate(7, (i) {
          final isWeekend = i == 0 || i == 6;
          return Expanded(
            child: Center(
              child: Text(
                days[i],
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color:
                      isWeekend ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({
    super.key,
    required this.month,
    required this.eventsMap,
    required this.selectedDay,
  });

  final DateTime month;
  final Map<String, List<CalendarEvent>> eventsMap;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDayNum = DateTime(month.year, month.month + 1, 0).day;

    // Sunday-first offset: Dart weekday 1=Mon 7=Sun → Sunday offset = weekday % 7
    final startOffset = firstDay.weekday % 7;
    final totalCells = ((startOffset + lastDayNum) / 7).ceil() * 7;

    final cellWidth =
        (MediaQuery.of(context).size.width - HomeSpacing.screenPadding * 2) /
            7;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.screenPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: cellWidth / (cellWidth + 4),
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayNum = index - startOffset + 1;
          final isInMonth = dayNum >= 1 && dayNum <= lastDayNum;

          if (!isInMonth) {
            return const SizedBox.shrink();
          }

          final date = DateTime(month.year, month.month, dayNum);
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final events = eventsMap[dateKey] ?? [];
          final isSelected = isSameDay(date, selectedDay);
          final isToday = isSameDay(date, DateTime.now());
          final isWeekend = date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday;

          return _DayCell(
            date: date,
            events: events,
            isSelected: isSelected,
            isToday: isToday,
            isWeekend: isWeekend,
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends ConsumerStatefulWidget {
  const _DayCell({
    required this.date,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.isWeekend,
  });

  final DateTime date;
  final List<CalendarEvent> events;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;

  @override
  ConsumerState<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends ConsumerState<_DayCell> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        ref.read(selectedDayProvider.notifier).select(widget.date);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primaryLight : null,
            borderRadius: BorderRadius.circular(HomeRadius.item),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DayNumber(
                day: widget.date.day,
                isSelected: widget.isSelected,
                isToday: widget.isToday,
                isWeekend: widget.isWeekend,
              ),
              const SizedBox(height: 2),
              _EventDots(events: widget.events),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayNumber extends StatelessWidget {
  const _DayNumber({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isWeekend,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color? bgColor;
    List<BoxShadow>? shadows;

    if (isSelected) {
      textColor = Colors.white;
      bgColor = AppColors.primary;
      shadows = const [HomeShadow.card];
    } else if (isToday) {
      textColor = Colors.white;
      bgColor = AppColors.textPrimary;
    } else if (isWeekend) {
      textColor = AppColors.primary;
      bgColor = null;
    } else {
      textColor = AppColors.textPrimary;
      bgColor = null;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
        boxShadow: shadows,
      ),
      child: Center(
        child: Text(
          '$day',
          style: AppTypography.h3.copyWith(
            fontSize: 13,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _EventDots extends StatelessWidget {
  const _EventDots({required this.events});
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox(height: 5);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: events.take(3).map((e) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: eventAccentColor(e.color),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }
}
