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

/// Singletons that must exist before the widget tree does.
///
/// [SharedPreferences] and [TokenStorage] are asynchronous to create but
/// synchronous to read, and the router needs to know at first frame whether
/// there is a session. Rather than make every consumer await, bootstrap
/// resolves them and overrides these two providers in `ProviderScope`, so the
/// rest of the graph can depend on plain values.
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

/// The one HTTP client. A second instance would not carry the session.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  final sessionEvents = ref.watch(sessionEventsProvider);

  final client = DioClient.create(
    tokenStorage: tokenStorage,
    onSessionExpired: () async {
      // Order matters: clear credentials first so nothing in-flight can
      // retry with the dead token, then announce it.
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

/// Live connectivity, for the offline banner and the sync trigger.
///
/// Starts optimistic. Assuming online until proven otherwise avoids flashing
/// an offline banner during the first probe, which is the common case.
@Riverpod(keepAlive: true)
Stream<bool> connectionStatus(Ref ref) =>
    ref.watch(networkInfoProvider).onStatusChange;

@riverpod
bool isOnline(Ref ref) =>
    ref.watch(connectionStatusProvider).value ?? true;

// ── Caches ───────────────────────────────────────────────────────────────
// Boxes are opened during bootstrap, so these are synchronous.

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
