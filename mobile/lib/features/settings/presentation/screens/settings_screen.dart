import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../features/auth/presentation/controllers/auth_notifier.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../controllers/settings_providers.dart';
import 'subscription_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ── Profile edit ────────────────────────────────────────────────────────

  void _editDisplayName(String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (_) => _saveDisplayName(ctx, ctrl.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => _saveDisplayName(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _saveDisplayName(BuildContext ctx, String name) async {
    if (name.trim().isEmpty) return;
    Navigator.pop(ctx);
    final ok = await ref
        .read(profileActionsProvider.notifier)
        .updateDisplayName(name.trim());
    if (!mounted) return;
    if (ok) {
      ref.invalidate(currentHouseholdMemberProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name updated.')));
    }
  }

  // ── Household rename ────────────────────────────────────────────────────

  void _editHouseholdName(String householdId, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Household name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (_) =>
              _saveHouseholdName(ctx, householdId, ctrl.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  _saveHouseholdName(ctx, householdId, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _saveHouseholdName(
      BuildContext ctx, String householdId, String name) async {
    if (name.trim().isEmpty) return;
    Navigator.pop(ctx);
    await ref
        .read(householdActionsProvider.notifier)
        .renameHousehold(householdId, name.trim());
    if (mounted) ref.invalidate(currentHouseholdMemberProvider);
  }

  // ── Invite link ─────────────────────────────────────────────────────────

  Future<void> _generateAndCopyInviteLink(String householdId) async {
    try {
      final link = await ref
          .read(householdRepositoryProvider)
          .generateInviteLink(householdId);
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invite link copied!')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not generate invite link.')));
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your household.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authActionsProvider.notifier).signOut();
      if (mounted) context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberAsync = ref.watch(currentHouseholdMemberProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final householdId = ref.watch(currentHouseholdIdProvider);
    final currentUserId =
        ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
    final isProAsync = ref.watch(isProUserProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Settings', style: theme.textTheme.titleLarge),
            floating: true,
            snap: true,
            surfaceTintColor: theme.colorScheme.surface,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // ── Profile ──
              _SectionHeader(label: 'Profile'),
              memberAsync.when(
                loading: () => const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Loading...')),
                error: (_, __) => const ListTile(
                    title: Text('Could not load profile')),
                data: (member) {
                  if (member == null) return const SizedBox.shrink();
                  final color = HexColor.fromHex(member.color);
                  return Column(children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: color,
                        backgroundImage: member.avatarUrl != null
                            ? NetworkImage(member.avatarUrl!)
                            : null,
                        child: member.avatarUrl == null
                            ? Text(
                                member.displayName.isNotEmpty
                                    ? member.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              )
                            : null,
                      ),
                      title: Text(member.displayName),
                      subtitle: Text(
                          member.role[0].toUpperCase() +
                              member.role.substring(1),
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _editDisplayName(member.displayName),
                    ),
                  ]);
                },
              ),
              const Divider(indent: 16, endIndent: 16),

              // ── Household ──
              _SectionHeader(label: 'Household'),
              memberAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (member) {
                  if (member == null || householdId == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(children: [
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Household name'),
                      subtitle: Text(member.householdId,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editHouseholdName(
                          householdId, member.householdId),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_add_outlined),
                      title: const Text('Invite a family member'),
                      trailing: const Icon(Icons.copy_outlined),
                      onTap: () =>
                          _generateAndCopyInviteLink(householdId),
                    ),
                  ]);
                },
              ),

              // ── Members list ──
              membersAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (members) {
                  if (members.isEmpty) return const SizedBox.shrink();
                  return ExpansionTile(
                    leading: const Icon(Icons.people_outline),
                    title: Text(
                        '${members.length} member${members.length == 1 ? '' : 's'}'),
                    children: members.map((m) {
                      final color = HexColor.fromHex(m.color);
                      final isMe = m.userId == currentUserId;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(
                            left: AppSpacing.xl + AppSpacing.lg,
                            right: AppSpacing.md),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: Text(
                            m.displayName.isNotEmpty
                                ? m.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(m.displayName),
                        subtitle: Text(
                          '${m.role[0].toUpperCase()}${m.role.substring(1)}${isMe ? ' · You' : ''}',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const Divider(indent: 16, endIndent: 16),

              // ── Subscription ──
              _SectionHeader(label: 'Subscription'),
              isProAsync.when(
                loading: () => const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Checking...')),
                error: (_, __) => const SizedBox.shrink(),
                data: (isPro) => isPro
                    ? ListTile(
                        leading: Icon(Icons.star,
                            color: theme.colorScheme.primary),
                        title: const Text('FamilySync Pro'),
                        subtitle: Text('Active',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600)),
                      )
                    : ListTile(
                        leading: Icon(Icons.star_border_outlined,
                            color: theme.colorScheme.primary),
                        title: const Text('Upgrade to Pro'),
                        subtitle: const Text('Unlock all features'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SubscriptionScreen()),
                        ),
                      ),
              ),
              const Divider(indent: 16, endIndent: 16),

              // ── Appearance ──
              _SectionHeader(label: 'Appearance'),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined, size: 16)),
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_android_outlined, size: 16)),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined, size: 16)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) => ref
                      .read(themeModeNotifierProvider.notifier)
                      .setMode(modes.first),
                  showSelectedIcon: false,
                ),
              ),
              const Divider(indent: 16, endIndent: 16),

              // ── Account ──
              _SectionHeader(label: 'Account'),
              ListTile(
                leading: Icon(Icons.logout,
                    color: theme.colorScheme.error),
                title: Text('Sign out',
                    style:
                        TextStyle(color: theme.colorScheme.error)),
                onTap: _confirmSignOut,
              ),
              const SizedBox(height: AppSpacing.xxl + 56),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      );
}
