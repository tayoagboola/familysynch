import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';

class AcceptInviteScreen extends ConsumerStatefulWidget {
  const AcceptInviteScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<AcceptInviteScreen> createState() =>
      _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends ConsumerState<AcceptInviteScreen> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        context.go(Routes.login);
        return;
      }

      // Validate token and check expiry
      final invite = await client
          .from('invite_tokens')
          .select('household_id, expires_at, used_at')
          .eq('token', widget.token)
          .maybeSingle();

      if (invite == null) {
        setState(() => _error = 'This invite link is invalid.');
        return;
      }
      if (invite['used_at'] != null) {
        setState(() => _error = 'This invite has already been used.');
        return;
      }
      final expiresAt = DateTime.parse(invite['expires_at'] as String);
      if (expiresAt.isBefore(DateTime.now())) {
        setState(() => _error = 'This invite has expired. Ask for a new one.');
        return;
      }

      final householdId = invite['household_id'] as String;

      // Assign a colour not already used
      final existingMembers = await client
          .from('household_members')
          .select('color')
          .eq('household_id', householdId);
      final usedColors =
          (existingMembers as List).map((m) => m['color'] as String).toSet();
      const palette = [
        '#2E7D6B', '#1565C0', '#AD1457', '#E65100',
        '#6A1B9A', '#00838F', '#558B2F', '#4E342E',
      ];
      final color =
          palette.firstWhere((c) => !usedColors.contains(c),
              orElse: () => palette.first);

      await client.from('household_members').insert({
        'household_id': householdId,
        'user_id': userId,
        'display_name': _nameCtrl.text.trim(),
        'color': color,
        'role': 'parent',
      });

      await client
          .from('invite_tokens')
          .update({'used_at': DateTime.now().toIso8601String()})
          .eq('token', widget.token);

      // Invalidate household cache so the redirect picks up the new member
      ref.invalidate(currentHouseholdMemberProvider);

      if (!mounted) return;
      context.go(Routes.calendar);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Join household')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + heading
                Center(
                  child: Column(children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.home_outlined,
                          size: 40,
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text("You've been invited!",
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your name to join the household.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Display name field
                TextFormField(
                  controller: _nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    hintText: 'e.g. Sarah',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter your name'
                      : null,
                  onFieldSubmitted: (_) => _accept(),
                ),

                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(children: [
                      Icon(Icons.warning_amber_outlined,
                          color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer)),
                      ),
                    ]),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _accept,
                    child: _loading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Join household'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
