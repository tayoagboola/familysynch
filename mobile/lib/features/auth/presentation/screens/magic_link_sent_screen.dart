import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';

class MagicLinkSentScreen extends StatelessWidget {
  const MagicLinkSentScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined,
                      size: 80, color: theme.colorScheme.primary)
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: AppSpacing.xl),
              Text('Check your inbox',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We sent a sign-in link to\n$email',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full)),
                ),
                onPressed: () => context.go(Routes.login),
                child: const Text('Use a different method'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
