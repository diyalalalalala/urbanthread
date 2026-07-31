import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class HiveBoxes {
  const HiveBoxes._();

  static const catalogue = 'catalogue_cache';

  static const account = 'account_cache';

  static const activity = 'activity_cache';

  static const outbox = 'outbox';

  static const _all = [catalogue, account, activity, outbox];

  static Future<void> init() async {
    await Hive.initFlutter();
    for (final name in _all) {
      if (!Hive.isBoxOpen(name)) await Hive.openBox<dynamic>(name);
    }
  }

  static Box<dynamic> box(String name) => Hive.box<dynamic>(name);

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
