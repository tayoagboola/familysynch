import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_typography.dart';
import '../providers/ai_providers.dart';
import 'ai_panel.dart';

// ── Nudge Card ────────────────────────────────────────────────────────────────
// Displayed on the home screen when FamilyAI has a proactive nudge.

class NudgeCard extends ConsumerStatefulWidget {
  const NudgeCard({super.key});

  @override
  ConsumerState<NudgeCard> createState() => _NudgeCardState();
}

class _NudgeCardState extends ConsumerState<NudgeCard> {
  bool _visible = false;
  String? _lastNudgeId;

  static const _bg1 = Color(0xFF1A1A2E);
  static const _bg2 = Color(0xFF2D2D5E);
  static const _purple = Color(0xFF6C63FF);
  static const _purple2 = Color(0xFFA78BFA);
  static const _white45 = Color(0x73FFFFFF);
  static const _white60 = Color(0x99FFFFFF);
  static const _white75 = Color(0xBFFFFFFF);
  static const _white10 = Color(0x1AFFFFFF);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nudge = ref.read(latestNudgeProvider);
    if (nudge != null && nudge.id != _lastNudgeId) {
      _lastNudgeId = nudge.id;
      // Trigger entrance animation on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  void _dismiss(String nudgeId) {
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(nudgeActionsProvider).markRead(nudgeId);
    });
  }

  void _askAI() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nudge = ref.watch(latestNudgeProvider);

    if (nudge == null) return const SizedBox.shrink();

    // Trigger entrance if new nudge arrives after first build
    if (nudge.id != _lastNudgeId) {
      _lastNudgeId = nudge.id;
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (mounted) setState(() => _visible = true);
      });
    }

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, -0.3),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_bg1, _bg2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(89),
                blurRadius: 48,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // AI icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_purple, _purple2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withAlpha(102),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAMILYAI · PROACTIVE NUDGE',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 10,
                            color: _white45,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nudge.title,
                          style: AppTypography.h3.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Dismiss button
                  GestureDetector(
                    onTap: () => _dismiss(nudge.id),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _white10,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: _white60,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Nudge body text
              Text(
                nudge.body,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: _white75,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _askAI,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_purple, _purple2],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            'Ask FamilyAI →',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _dismiss(nudge.id),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: _white10,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            'Got it',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 12,
                              color: _white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
