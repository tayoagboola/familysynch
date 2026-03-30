import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/ai_fab.dart';
import '../../../ai/presentation/widgets/nudge_card.dart';
import '../widgets/calendar_strip_section.dart';
import '../widgets/feed_section.dart';
import '../widgets/greeting_row.dart';
import '../widgets/members_row.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/tasks_section.dart';
import '../widgets/today_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // One controller per section for staggered entrance
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const _sections = 6; // header, banner, quick actions, calendar, tasks, feed
  static const _delays = [50, 100, 150, 200, 250, 300];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _sections,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _fadeAnims = _controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _slideAnims = _controllers
        .map((c) =>
            Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _sections; i++) {
      await Future.delayed(Duration(milliseconds: _delays[i]));
      if (mounted) _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: const AIFab(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Status bar safe area
          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.top),
          ),

          // ── AI Nudge Card ─────────────────────────────────────────────
          const SliverToBoxAdapter(child: NudgeCard()),

          // ── Header: Greeting + Members ──────────────────────────────
          SliverToBoxAdapter(
            child: _animated(
              0,
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingRow(),
                  MembersRow(),
                  SizedBox(height: HomeSpacing.sectionGap),
                ],
              ),
            ),
          ),

          // ── Today Banner ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _animated(1, const TodayBanner()),
          ),

          // ── Quick Actions ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _animated(
              2,
              const Padding(
                padding: EdgeInsets.only(bottom: HomeSpacing.sectionGap),
                child: QuickActionsSection(),
              ),
            ),
          ),

          // ── Calendar Strip ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _animated(
              3,
              const Padding(
                padding: EdgeInsets.only(bottom: HomeSpacing.sectionGap),
                child: CalendarStripSection(),
              ),
            ),
          ),

          // ── Today's Tasks ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _animated(
              4,
              const Padding(
                padding: EdgeInsets.only(bottom: HomeSpacing.sectionGap),
                child: TasksSection(),
              ),
            ),
          ),

          // ── Family Feed ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _animated(
              5,
              const Padding(
                padding: EdgeInsets.only(bottom: HomeSpacing.sectionGap),
                child: FeedSection(),
              ),
            ),
          ),

          // Bottom padding for FAB + nav
          SliverToBoxAdapter(
            child: SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }
}
