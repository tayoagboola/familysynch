import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/ai_fab.dart';
import '../controllers/calendar_providers.dart';
import '../providers/calendar_extra_providers.dart';
import '../widgets/member_filter_row.dart';
import '../widgets/month_grid.dart';
import '../widgets/timeline_section.dart';
import '../widgets/upcoming_section.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: const AIFab(),
      body: Column(
        children: [
          // ── Fixed header ──────────────────────────────────────────────
          _CalendarHeader(),
          // ── Scrollable bottom half ────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Day header
                const SliverToBoxAdapter(
                  child: _DayHeader(),
                ),
                // Timeline
                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 8, bottom: HomeSpacing.sectionGap),
                    child: TimelineSection(),
                  ),
                ),
                // Upcoming
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: HomeSpacing.sectionGap),
                    child: UpcomingSection(),
                  ),
                ),
                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fixed Calendar Header ─────────────────────────────────────────────────────

class _CalendarHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _MonthNavRow(),
            const MemberFilterRow(),
            const SizedBox(height: 4),
            const MonthGrid(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Month Navigation Row ──────────────────────────────────────────────────────

class _MonthNavRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(HomeSpacing.screenPadding, 12,
              HomeSpacing.screenPadding, 8),
      child: Row(
        children: [
          // Previous month arrow
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            onTap: () =>
                ref.read(calendarMonthProvider.notifier).previousMonth(),
          ),
          const SizedBox(width: 8),
          // Next month arrow
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            onTap: () =>
                ref.read(calendarMonthProvider.notifier).nextMonth(),
          ),
          const SizedBox(width: 12),
          // Month + year text
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.h1.copyWith(fontSize: 22),
                children: [
                  TextSpan(
                    text: DateFormat('MMMM').format(month),
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: ' ${month.year}',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          // Today button
          _TodayButton(),
          const SizedBox(width: 8),
          // View toggle (placeholder)
          _IconButton(
            icon: Icons.grid_view_rounded,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatefulWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_NavArrow> createState() => _NavArrowState();
}

class _NavArrowState extends State<_NavArrow> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TodayButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(calendarMonthProvider.notifier).jumpToToday();
        ref.read(selectedDayProvider.notifier).select(DateTime.now());
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            'Today',
            style: AppTypography.label.copyWith(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.size = 16});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: size, color: AppColors.textSecondary),
    );
  }
}

// ── Day Header (scrollable) ───────────────────────────────────────────────────

class _DayHeader extends ConsumerWidget {
  const _DayHeader();

  String _weatherEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌤️';
    if (h < 17) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final events = ref.watch(calendarSelectedDayEventsProvider);
    final isToday = _isToday(selectedDay);

    final dateLabel = isToday
        ? 'Today'
        : DateFormat('EEEE, MMMM d').format(selectedDay);

    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeSpacing.screenPadding,
          HomeSpacing.sectionGap, HomeSpacing.screenPadding, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dateLabel,
                      style: AppTypography.h2.copyWith(
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    if (isToday)
                      Text(
                        _weatherEmoji(),
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  events.isEmpty
                      ? 'No events'
                      : '${events.length} event${events.length == 1 ? '' : 's'}',
                  style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Add event button
          GestureDetector(
            onTap: () => context.push(Routes.eventNew),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Add',
                    style: AppTypography.label.copyWith(
                        color: AppColors.primary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}
