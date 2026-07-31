import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../session/session_events.dart';
import '../storage/cache_store.dart';
import '../storage/hive_boxes.dart';
import '../storage/preferences_service.dart';
import '../storage/token_storage.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) => throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in ProviderScope. '
      'See bootstrap() in main.dart.',
    );

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => throw UnimplementedError(
      'tokenStorageProvider must be overridden in ProviderScope. '
      'See bootstrap() in main.dart.',
    );

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

@Riverpod(keepAlive: true)
PreferencesService preferencesService(Ref ref) =>
    PreferencesService(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
SessionEvents sessionEvents(Ref ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  final sessionEvents = ref.watch(sessionEventsProvider);

  final client = DioClient.create(
    tokenStorage: tokenStorage,
    onSessionExpired: () async {
      await tokenStorage.clear();
      await preferences.clearSession();
      await HiveBoxes.clearUserData();
      sessionEvents.notifyExpired();
    },
  );

  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) => Connectivity();

@Riverpod(keepAlive: true)
InternetConnection internetConnection(Ref ref) => InternetConnection();

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) => NetworkInfoImpl(
      connectivity: ref.watch(connectivityProvider),
      internetConnection: ref.watch(internetConnectionProvider),
    );

@Riverpod(keepAlive: true)
Stream<bool> connectionStatus(Ref ref) =>
    ref.watch(networkInfoProvider).onStatusChange;

@riverpod
bool isOnline(Ref ref) =>
    ref.watch(connectionStatusProvider).value ?? true;

@Riverpod(keepAlive: true)
CacheStore catalogueCache(Ref ref) =>
    CacheStore(HiveBoxes.box(HiveBoxes.catalogue));

@Riverpod(keepAlive: true)
CacheStore accountCache(Ref ref) =>
    CacheStore(HiveBoxes.box(HiveBoxes.account));

@Riverpod(keepAlive: true)
CacheStore activityCache(Ref ref) =>
    CacheStore(HiveBoxes.box(HiveBoxes.activity));

@Riverpod(keepAlive: true)
CacheStore outboxCache(Ref ref) => CacheStore(HiveBoxes.box(HiveBoxes.outbox));
