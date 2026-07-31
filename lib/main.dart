import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_boxes.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (preferences, tokenStorage) = await _bootstrap();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
      child: const UrbanThreadApp(),
    ),
  );
}

Future<(SharedPreferences, TokenStorage)> _bootstrap() async {
  await AppConfig.load();
  await HiveBoxes.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final preferences = await SharedPreferences.getInstance();

  final tokenStorage = TokenStorage(
    const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );
  await tokenStorage.prime();

  return (preferences, tokenStorage);
}

class UrbanThreadApp extends ConsumerWidget {
  const UrbanThreadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'UrbanThread',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
