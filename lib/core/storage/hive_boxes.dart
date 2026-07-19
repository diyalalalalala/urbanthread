import 'package:hive_ce_flutter/hive_flutter.dart';

/// Names and lifecycle of every Hive box in the app.
///
/// Boxes are split by *eviction policy*, not by feature. Catalogue data is
/// disposable and can be cleared wholesale to reclaim space; the cart and
/// wishlist mirror server state the user expects to survive; the outbox holds
/// writes that have not reached the server yet and must never be dropped.
abstract final class HiveBoxes {
  const HiveBoxes._();

  /// Catalogue reads: products, categories, brands, home sections, facets.
  /// Safe to clear at any time — it will be re-fetched.
  static const catalogue = 'catalogue_cache';

  /// The user's own data: cart, wishlist, profile, orders, addresses.
  static const account = 'account_cache';

  /// Recently viewed and search history. Cleared when the user asks, not by
  /// the app.
  static const activity = 'activity_cache';

  /// Mutations made offline, replayed when connectivity returns.
  static const outbox = 'outbox';

  static const _all = [catalogue, account, activity, outbox];

  /// Opens every box. Call once during bootstrap — [CacheStore] assumes the
  /// boxes are already open so reads can stay synchronous.
  static Future<void> init() async {
    await Hive.initFlutter();
    for (final name in _all) {
      // Typed as dynamic on purpose: entries are plain JSON maps rather than
      // adapter-backed objects, so a DTO gaining a field never invalidates
      // what is already on disk.
      if (!Hive.isBoxOpen(name)) await Hive.openBox<dynamic>(name);
    }
  }

  static Box<dynamic> box(String name) => Hive.box<dynamic>(name);

  /// Drops everything tied to the signed-in user. Called on logout so the
  /// next account to sign in on this device sees none of it. The catalogue is
  /// deliberately spared — it is public data and re-downloading it wastes the
  /// user's bandwidth.
  static Future<void> clearUserData() async {
    await Future.wait([
      box(account).clear(),
      box(activity).clear(),
      box(outbox).clear(),
    ]);
  }

  static Future<void> clearAll() async {
    await Future.wait(_all.map((name) => box(name).clear()));
  }
}
