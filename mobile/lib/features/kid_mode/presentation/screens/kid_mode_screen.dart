import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../kid_theme.dart';
import '../providers/kid_providers.dart';

class KidModeScreen extends ConsumerStatefulWidget {
  const KidModeScreen({super.key, required this.memberId});
  final String memberId;

  @override
  ConsumerState<KidModeScreen> createState() => _KidModeScreenState();
}

class _KidModeScreenState extends ConsumerState<KidModeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(householdMembersMapProvider)[widget.memberId];
    final name = member?.displayName.split(' ').first ?? 'Friend';
    final initials = member != null ? _initials(member.displayName) : '?';

    return Scaffold(
      backgroundColor: kidBg,
      body: Column(
        children: [
          _KidHeader(
            name: name,
            memberId: widget.memberId,
            initials: initials,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: IndexedStack(
                key: ValueKey(_navIndex),
                index: _navIndex,
                children: [
                  _KidHomeView(memberId: widget.memberId),
                  _KidTasksView(memberId: widget.memberId),
                  _KidTodayView(memberId: widget.memberId),
                  _KidBadgesView(memberId: widget.memberId),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _KidBottomNav(
        activeIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

// ── Kid Header ────────────────────────────────────────────────────────────────

class _KidHeader extends ConsumerWidget {
  const _KidHeader({
    required this.name,
    required this.memberId,
    required this.initials,
  });

  final String name;
  final String memberId;
  final String initials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpAsync = ref.watch(kidXPProvider(memberId));
    final xp = xpAsync.valueOrNull ?? KidXP.initial();
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(gradient: kidHeaderGradient),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0x26FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0x1AFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(22, topPadding + 12, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KidGreetingRow(
                  name: name,
                  memberId: memberId,
                  initials: initials,
                ),
                const SizedBox(height: 14),
                _XPBar(xp: xp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KidGreetingRow extends ConsumerWidget {
  const _KidGreetingRow({
    required this.name,
    required this.memberId,
    required this.initials,
  });

  final String name;
  final String memberId;
  final String initials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey there! 👋',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(204),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "$name's Space 🦁",
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Avatar button
        GestureDetector(
          onLongPress: () => _showExitSheet(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(64),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withAlpha(102), width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.fredoka(
                    fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ParentalGateSheet(),
    );
  }
}

class _XPBar extends StatelessWidget {
  const _XPBar({required this.xp});
  final KidXP xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Stars
          Text(
            xp.starsForLevel,
            style: const TextStyle(fontSize: 20, letterSpacing: 2),
          ),
          const SizedBox(width: 10),
          // XP info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${xp.currentLevel} ${xp.levelName} — '
                  '${(xp.levelProgress * 100).round()}% to next level',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: xp.levelProgress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha(64),
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Points counter
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${xp.totalPoints}',
                style: GoogleFonts.fredoka(
                    fontSize: 20, color: Colors.white),
              ),
              Text(
                'POINTS',
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withAlpha(179),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Kid Bottom Nav ────────────────────────────────────────────────────────────

class _KidBottomNav extends StatelessWidget {
  const _KidBottomNav({
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final void Function(int) onTap;

  static const _tabs = [
    ('🏠', 'Home'),
    ('✅', 'Tasks'),
    ('📅', 'Today'),
    ('🏆', 'Badges'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 82 + bottomPadding,
      decoration: const BoxDecoration(
        color: kidSurface,
        border: Border(top: BorderSide(color: kidBorder, width: 2)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = activeIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Active indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 22 : 0,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? kidPrimary : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedScale(
                    scale: isActive ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _tabs[i].$1,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tabs[i].$2,
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      color: isActive
                          ? kidPrimary
                          : kidTextSoft,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _KidSectionTitle extends StatelessWidget {
  const _KidSectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 18,
          color: kidTextPrimary,
        ),
      ),
    );
  }
}

// ── Home View ─────────────────────────────────────────────────────────────────

class _KidHomeView extends StatelessWidget {
  const _KidHomeView({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _MyTasksSection(memberId: memberId)),
        SliverToBoxAdapter(
            child: _TodayScheduleSection(memberId: memberId)),
        SliverToBoxAdapter(child: _BadgeShelfSection(memberId: memberId)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Tasks View ────────────────────────────────────────────────────────────────

class _KidTasksView extends StatelessWidget {
  const _KidTasksView({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _MyTasksSection(memberId: memberId, showAll: true)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Today View ────────────────────────────────────────────────────────────────

class _KidTodayView extends StatelessWidget {
  const _KidTodayView({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
            child: _TodayScheduleSection(memberId: memberId, showAll: true)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Badges View ───────────────────────────────────────────────────────────────

class _KidBadgesView extends StatelessWidget {
  const _KidBadgesView({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
            child: _BadgeShelfSection(memberId: memberId, showAll: true)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── My Tasks Section ──────────────────────────────────────────────────────────

class _MyTasksSection extends ConsumerWidget {
  const _MyTasksSection({required this.memberId, this.showAll = false});
  final String memberId;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(kidTasksProvider(memberId));
    final displayed = showAll ? tasks : tasks.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _KidSectionTitle('🎯 My Tasks'),
        if (tasks.isEmpty)
          _KidEmptySection(emoji: '🎉', label: "All done! You're awesome!")
        else
          ...List.generate(
            displayed.length,
            (i) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 350 + i * 80),
              curve: Curves.easeOut,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: _KidTaskCard(
                task: displayed[i],
                memberId: memberId,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Kid Task Card ─────────────────────────────────────────────────────────────

class _KidTaskCard extends ConsumerStatefulWidget {
  const _KidTaskCard({required this.task, required this.memberId});
  final dynamic task; // Task entity
  final String memberId;

  @override
  ConsumerState<_KidTaskCard> createState() => _KidTaskCardState();
}

class _KidTaskCardState extends ConsumerState<_KidTaskCard>
    with TickerProviderStateMixin {
  late bool _completed;
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;
  late final ConfettiController _confettiController;
  bool _showPoints = false;

  @override
  void initState() {
    super.initState();
    _completed = widget.task.completed as bool;
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _checkScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _checkController, curve: Curves.elasticOut));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _toggleTask() async {
    final newVal = !_completed;
    setState(() => _completed = newVal);
    _checkController.forward(from: 0);

    if (newVal) {
      _confettiController.play();
      setState(() => _showPoints = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showPoints = false);
      });
    }

    await ref.read(kidTaskActionsProvider).completeTask(
          widget.task.id as String,
          newVal,
        );
  }

  // Pick emoji based on task title keywords
  String _taskEmoji() {
    final title = (widget.task.title as String).toLowerCase();
    if (title.contains('read') || title.contains('book')) return '📚';
    if (title.contains('brush') || title.contains('teeth')) return '🦷';
    if (title.contains('clean') || title.contains('room')) return '🧹';
    if (title.contains('homework') || title.contains('school')) return '✏️';
    if (title.contains('exercise') || title.contains('sport')) return '⚽';
    if (title.contains('eat') || title.contains('food')) return '🍎';
    if (title.contains('recycle') || title.contains('trash')) return '♻️';
    return '⭐';
  }

  Color _iconBg() {
    final emoji = _taskEmoji();
    return switch (emoji) {
      '📚' => kidPrimaryLight,
      '🦷' => kidBlueLight,
      '♻️' => kidGreenLight,
      '✏️' => kidPurpleLight,
      '⚽' => kidGreenLight,
      _ => kidYellowLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.task.points as int;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Confetti
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 8,
              colors: const [
                kidPrimary, kidYellow, kidGreen, kidPurple
              ],
              shouldLoop: false,
            ),
          ),
        ),
        // Card
        GestureDetector(
          onTap: _toggleTask,
          child: AnimatedOpacity(
            opacity: _completed ? 0.75 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _completed ? kidGreenLight : kidSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _completed ? kidGreen : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: _completed
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 24,
                          offset: Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _iconBg(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(_taskEmoji(),
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title as String,
                          style: GoogleFonts.fredoka(
                            fontSize: 17,
                            color: _completed
                                ? kidTextSoft
                                : kidTextPrimary,
                            decoration: _completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.task.dueDate != null)
                              Text(
                                DateFormat('h:mm a')
                                    .format(widget.task.dueDate!),
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kidTextSoft,
                                ),
                              ),
                            if (points > 0) ...[
                              const SizedBox(width: 8),
                              _PointsBadge(points: points),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Check button
                  AnimatedBuilder(
                    animation: _checkScale,
                    builder: (_, __) => Transform.scale(
                      scale: _checkScale.value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _completed ? kidGreen : kidSurface2,
                          borderRadius: BorderRadius.circular(12),
                          border: _completed
                              ? null
                              : Border.all(
                                  color: const Color(0xFFE8E4DE),
                                  width: 3,
                                ),
                          boxShadow: _completed
                              ? [
                                  BoxShadow(
                                    color: kidGreen.withAlpha(102),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: _completed
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Floating points animation
        if (_showPoints && widget.task.points > 0)
          Positioned(
            right: 36,
            top: 0,
            child: _FloatingPoints(points: widget.task.points as int),
          ),
      ],
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kidYellowLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kidYellow, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            '$points pts',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              color: const Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingPoints extends StatefulWidget {
  const _FloatingPoints({required this.points});
  final int points;

  @override
  State<_FloatingPoints> createState() => _FloatingPointsState();
}

class _FloatingPointsState extends State<_FloatingPoints>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _translateY = Tween<double>(begin: 0, end: -40)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Text(
            '+⭐ ${widget.points} pts',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: kidPrimary,
              shadows: [
                const Shadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Today Schedule Section ────────────────────────────────────────────────────

class _TodayScheduleSection extends ConsumerWidget {
  const _TodayScheduleSection(
      {required this.memberId, this.showAll = false});
  final String memberId;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(kidTodayEventsProvider(memberId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _KidSectionTitle("📅 Today's Plan"),
        if (events.isEmpty)
          _KidEmptySection(emoji: '😊', label: 'No events today — enjoy your day!')
        else
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: events.map((e) => _KidEventCard(event: e)).toList(),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _KidEventCard extends StatelessWidget {
  const _KidEventCard({required this.event});
  final dynamic event;

  String _emoji() {
    final title = (event.title as String).toLowerCase();
    if (title.contains('school') || title.contains('class')) return '🏫';
    if (title.contains('sport') || title.contains('game')) return '⚽';
    if (title.contains('music') || title.contains('guitar')) return '🎵';
    if (title.contains('art') || title.contains('draw')) return '🎨';
    if (title.contains('doctor') || title.contains('appoint')) return '🏥';
    if (title.contains('party') || title.contains('birthday')) return '🎉';
    return '📌';
  }

  Color _bgColor() {
    final emoji = _emoji();
    return switch (emoji) {
      '🏫' => kidBlueLight,
      '⚽' => kidGreenLight,
      '🎵' => kidPurpleLight,
      '🎨' => kidPrimaryLight,
      '🏥' => kidYellowLight,
      '🎉' => kidPrimaryLight,
      _ => kidSurface2,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kidSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _bgColor(),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(_emoji(),
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.title as String,
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: kidTextPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('h:mm a').format(event.startTime as DateTime),
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kidTextSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge Shelf Section ───────────────────────────────────────────────────────

class _BadgeShelfSection extends ConsumerWidget {
  const _BadgeShelfSection(
      {required this.memberId, this.showAll = false});
  final String memberId;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(kidBadgesProvider(memberId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _KidSectionTitle('🏆 My Badges'),
        badgesAsync.when(
          loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator())),
          error: (_, __) => _KidEmptySection(
              emoji: '😅', label: 'Could not load badges'),
          data: (badges) {
            if (badges.isEmpty) {
              return _KidEmptySection(
                  emoji: '🔒', label: 'Complete tasks to earn badges!');
            }
            final displayed = showAll ? badges : badges.take(8).toList();
            return SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: displayed
                    .map((b) => _BadgeCard(badge: b))
                    .toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BadgeCard extends StatefulWidget {
  const _BadgeCard({required this.badge});
  final KidBadge badge;

  @override
  State<_BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<_BadgeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.badge.isEarned) {
      _controller.repeat(reverse: true);
    }
    _rotation = Tween<double>(begin: -0.035, end: 0.035).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeSheet(context),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _rotation,
              builder: (_, child) => Transform.rotate(
                angle: widget.badge.isEarned ? _rotation.value : 0,
                child: child,
              ),
              child: Opacity(
                opacity: widget.badge.isEarned ? 1.0 : 0.4,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.badge.gradientColor1,
                        widget.badge.gradientColor2,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: widget.badge.isEarned
                        ? [
                            BoxShadow(
                              color:
                                  widget.badge.gradientColor1.withAlpha(102),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.badge.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.badge.name,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kidTextSoft,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeDetailSheet(badge: widget.badge),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  const _BadgeDetailSheet({required this.badge});
  final KidBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: kidSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4DE),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [badge.gradientColor1, badge.gradientColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: badge.isEarned
                  ? [
                      BoxShadow(
                        color: badge.gradientColor1.withAlpha(102),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(badge.emoji,
                  style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            badge.name,
            style: GoogleFonts.fredoka(
                fontSize: 22, color: kidTextPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            badge.isEarned
                ? badge.description
                : '${badge.description}\n\nKeep going — you can earn this!',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kidTextSoft,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (badge.isEarned && badge.earnedAt != null)
            Text(
              '✨ Earned on ${DateFormat('MMMM d, y').format(badge.earnedAt!)}',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kidPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty Section ─────────────────────────────────────────────────────────────

class _KidEmptySection extends StatelessWidget {
  const _KidEmptySection({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.fredoka(
                  fontSize: 16, color: kidTextSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Parental Gate Sheet ───────────────────────────────────────────────────────

class _ParentalGateSheet extends ConsumerStatefulWidget {
  const _ParentalGateSheet();

  @override
  ConsumerState<_ParentalGateSheet> createState() =>
      _ParentalGateSheetState();
}

class _ParentalGateSheetState extends ConsumerState<_ParentalGateSheet> {
  final _pin = <int>[];
  bool _error = false;

  // In a real app, PIN would be fetched from household settings
  static const _correctPin = [1, 2, 3, 4];

  void _tapDigit(int d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin.add(d);
      _error = false;
    });
    if (_pin.length == 4) {
      _checkPin();
    }
  }

  void _checkPin() {
    if (_pin.length == 4 && _listEquals(_pin, _correctPin)) {
      Navigator.pop(context);
      context.go('/home');
    } else {
      setState(() {
        _error = true;
        _pin.clear();
      });
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, 24 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: kidSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4DE),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Parent Zone 🔒',
              style: GoogleFonts.fredoka(
                  fontSize: 22, color: kidTextPrimary)),
          const SizedBox(height: 6),
          Text('Enter parent PIN to exit',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kidTextSoft)),
          const SizedBox(height: 20),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? (_error ? AppColors.red : kidPrimary)
                      : const Color(0xFFE8E4DE),
                ),
              ),
            ),
          ),
          if (_error) ...[
            const SizedBox(height: 8),
            Text('Wrong PIN, try again!',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                )),
          ],
          const SizedBox(height: 20),
          // Numpad
          ...List.generate(3, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (col) {
                  final digit = row * 3 + col + 1;
                  return _PinButton(
                      digit: digit, onTap: () => _tapDigit(digit));
                }),
              ),
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 80),
              const SizedBox(width: 10),
              _PinButton(digit: 0, onTap: () => _tapDigit(0)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (_pin.isNotEmpty) setState(() => _pin.removeLast());
                },
                child: Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kidSurface2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.backspace_outlined,
                      color: kidTextSoft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton({required this.digit, required this.onTap});
  final int digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: kidSurface2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Center(
          child: Text(
            '$digit',
            style: GoogleFonts.fredoka(
                fontSize: 24, color: kidTextPrimary),
          ),
        ),
      ),
    );
  }
}
