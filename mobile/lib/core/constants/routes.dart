abstract class Routes {
  static const String login = '/auth/login';
  static const String magicLinkSent = '/auth/magic-link-sent';
  static const String householdNew = '/household/new';
  static const String inviteSent = '/household/invite-sent';
  static const String inviteBase = '/invite';
  static String invite(String token) => '/invite/$token';

  static const String home = '/home';
  static const String calendar = '/home/calendar';
  static const String eventNew = '/home/calendar/event/new';
  static const String eventEdit = '/home/calendar/event/edit';

  static const String tasks = '/home/tasks';
  static const String taskNew = '/home/tasks/task/new';

  static const String grocery = '/home/grocery';
  static const String feed = '/home/feed';
  static const String settings = '/home/settings';
  static const String householdSettings = '/home/settings/household';
  static const String profile = '/home/settings/profile';
  static const String members = '/home/settings/members';
  static const String subscription = '/home/settings/subscription';

  static const String kidHome = '/kid';
  static const String kidTasks = '/kid/tasks';
  static const String kidCalendar = '/kid/calendar';
}
