import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../features/ai/presentation/providers/ai_providers.dart';
import '../../features/ai/presentation/widgets/ai_panel.dart';

class AIFab extends ConsumerStatefulWidget {
  const AIFab({super.key});

  @override
  ConsumerState<AIFab> createState() => _AIFabState();
}

class _AIFabState extends ConsumerState<AIFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openAIPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNotification = ref.watch(nudgeCountProvider) > 0;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aiAccent.withAlpha(
                        (76 + 51 * _pulseAnim.value).round()),
                    blurRadius: 16 + 8 * _pulseAnim.value,
                    spreadRadius: 1 + 2 * _pulseAnim.value,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.aiAccent, AppColors.aiAccent2],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openAIPanel(context),
                  child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
            if (hasNotification)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
