import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'shared/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvFileIfPresent();

  final supabaseUrl = _readConfig('SUPABASE_URL');
  final supabaseAnonKey = _readConfig('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase config. Set SUPABASE_URL and SUPABASE_ANON_KEY in '
      'mobile/.env or pass them with --dart-define.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await Firebase.initializeApp();
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: FamilySyncApp()));
}

Future<void> _loadEnvFileIfPresent() async {
  try {
    await dotenv.load(fileName: '.env');
  } on EmptyEnvFileError {
    // Allow local startup to continue when .env exists but is blank.
  } on FileNotFoundError {
    // Allow configs to come from --dart-define instead.
  }
}

String _readConfig(String key) {
  final dotenvValue = dotenv.env[key];
  if (dotenvValue != null && dotenvValue.isNotEmpty) {
    return dotenvValue;
  }

  switch (key) {
    case 'SUPABASE_URL':
      return const String.fromEnvironment('SUPABASE_URL');
    case 'SUPABASE_ANON_KEY':
      return const String.fromEnvironment('SUPABASE_ANON_KEY');
    default:
      return '';
  }
}
