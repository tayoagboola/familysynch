import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/routes.dart';
import '../features/auth/presentation/controllers/auth_notifier.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/magic_link_sent_screen.dart';
import '../features/calendar/domain/entities/calendar_event.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/calendar/presentation/screens/event_form_screen.dart';
import '../features/feed/presentation/screens/feed_screen.dart';
import '../features/grocery/presentation/screens/grocery_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/household/presentation/screens/accept_invite_screen.dart';
import '../features/household/presentation/screens/household_setup_screen.dart';
import '../features/household/presentation/screens/invite_confirmation_screen.dart';
import '../features/kid_mode/presentation/screens/kid_calendar_screen.dart';
import '../features/kid_mode/presentation/screens/kid_tasks_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tasks/presentation/screens/task_board_screen.dart';
import '../shared/providers/household_providers.dart';
import '../shared/providers/supabase_provider.dart';
import '../shared/widgets/bottom_nav.dart';

part 'router.g.dart';

// ── Home Shell ────────────────────────────────────────────────────────────────

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  static int _tabIndex(String? path) {
    if (path == null) return 0;
    if (path == Routes.home) return 0;
    if (path.startsWith(Routes.calendar)) return 1;
    if (path.startsWith(Routes.tasks)) return 2;
    if (path.startsWith(Routes.grocery)) return 3;
    if (path.startsWith(Routes.feed)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).fullPath;
    final incompleteTasks = ref
        .watch(householdMembersProvider)
        .maybeWhen(orElse: () => 0, data: (_) => 0);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNav(
        activeIndex: _tabIndex(location),
        taskBadgeCount: incompleteTasks,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go(Routes.home);
            case 1:
              context.go(Routes.calendar);
            case 2:
              context.go(Routes.tasks);
            case 3:
              context.go(Routes.grocery);
            case 4:
              context.go(Routes.feed);
          }
        },
      ),
    );
  }
}

// ── Kid Shell ─────────────────────────────────────────────────────────────────

class KidShell extends StatelessWidget {
  const KidShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).fullPath;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: path == Routes.kidCalendar ? 1 : 0,
        onDestinationSelected: (i) => i == 0
            ? context.go(Routes.kidTasks)
            : context.go(Routes.kidCalendar),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline), label: 'My Tasks'),
          NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
        ],
      ),
    );
  }
}

// ── Router ────────────────────────────────────────────────────────────────────

@riverpod
GoRouter router(Ref ref) {
  final authStream = ref.watch(authUserProvider);
  final supabase = ref.watch(supabaseClientProvider);

  return GoRouter(
    initialLocation: Routes.login,
    redirect: (context, state) async {
      final user = authStream.valueOrNull;
      final path = state.fullPath ?? '';
      final isAuthPath = path.startsWith('/auth');
      final isInvitePath = path.startsWith('/invite');

      if (user == null) {
        return (isAuthPath || isInvitePath) ? null : Routes.login;
      }

      // Authenticated — on auth screen, redirect appropriately
      if (isAuthPath) {
        try {
          final member = await supabase
              .from('household_members')
              .select('role')
              .eq('user_id', user.id)
              .limit(1)
              .maybeSingle();

          if (member == null) return Routes.householdNew;
          if (member['role'] == 'child') return Routes.kidTasks;
          return Routes.home;
        } catch (_) {
          return Routes.householdNew;
        }
      }

      return null;
    },
    routes: [
      // ── Auth ──
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.magicLinkSent,
        builder: (_, state) => MagicLinkSentScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),

      // ── Invite ──
      GoRoute(
        path: '/invite',
        builder: (_, state) => AcceptInviteScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      // ── Household setup ──
      GoRoute(
        path: Routes.householdNew,
        builder: (_, __) => const HouseholdSetupScreen(),
      ),
      GoRoute(
        path: Routes.inviteSent,
        builder: (_, __) => const InviteConfirmationScreen(),
      ),

      // ── Home shell ──
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.calendar,
            builder: (_, __) => const CalendarScreen(),
            routes: [
              GoRoute(
                path: 'event/new',
                builder: (_, __) => const EventFormScreen(),
              ),
              GoRoute(
                path: 'event/edit',
                builder: (_, state) =>
                    EventFormScreen(event: state.extra as CalendarEvent?),
              ),
            ],
          ),
          GoRoute(
            path: Routes.tasks,
            builder: (_, __) => const TaskBoardScreen(),
          ),
          GoRoute(
            path: Routes.grocery,
            builder: (_, __) => const GroceryScreen(),
          ),
          GoRoute(
            path: Routes.feed,
            builder: (_, __) => const FeedScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),

      // ── Kid shell ──
      ShellRoute(
        builder: (_, __, child) => KidShell(child: child),
        routes: [
          GoRoute(
            path: Routes.kidTasks,
            builder: (_, __) => const KidTasksScreen(),
          ),
          GoRoute(
            path: Routes.kidCalendar,
            builder: (_, __) => const KidCalendarScreen(),
          ),
        ],
      ),
    ],
  );
}
