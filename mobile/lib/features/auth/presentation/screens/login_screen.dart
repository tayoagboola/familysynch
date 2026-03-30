import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../controllers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _showMagicLink = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    await ref.read(authActionsProvider.notifier).signInWithMagicLink(email);
    if (!mounted) return;
    context.go('${Routes.magicLinkSent}?email=${Uri.encodeComponent(email)}');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authActionsProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'FamilySync',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'One app for the whole household.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _SocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                onPressed: isLoading
                    ? null
                    : () =>
                        ref.read(authActionsProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SocialButton(
                label: 'Continue with Apple',
                icon: Icons.apple,
                onPressed: isLoading
                    ? null
                    : () =>
                        ref.read(authActionsProvider.notifier).signInWithApple(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: Text('or',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  const Expanded(child: Divider()),
                ]),
              ),
              if (_showMagicLink) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendMagicLink(),
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: isLoading ? null : _sendMagicLink,
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send magic link'),
                ),
              ] else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: () => setState(() => _showMagicLink = true),
                  child: const Text('Continue with email'),
                ),
              const Spacer(),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy.',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton(
      {required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}
