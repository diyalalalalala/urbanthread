import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/core/network/network_info.dart';
import 'package:urbanthread/core/storage/cache_store.dart';
import 'package:urbanthread/features/authentication/data/models/user_model.dart';
import 'package:urbanthread/features/authentication/domain/entities/user.dart';
import 'package:urbanthread/features/checkout/data/datasource/checkout_remote_datasource.dart';
import 'package:urbanthread/features/checkout/data/models/checkout_models.dart';
import 'package:urbanthread/features/checkout/data/repositories/address_repository_impl.dart';
import 'package:urbanthread/features/checkout/domain/entities/address_draft.dart';

import '../../helpers/api_fixtures.dart';

class MockCheckoutRemoteDataSource extends Mock
    implements CheckoutRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

/// Full CRUD over the address book — `GET`, `POST`, `PATCH` and `DELETE` on
/// `/addresses`, plus the `default` promotion.
///
/// The cache is the real [CacheStore] over a temporary Hive box rather than a
/// mock: the interesting behaviour here is *when* a cached book is served and
/// when it is thrown away, and a mock would only assert that some method was
/// called, not that the next read returns the right thing.
void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late CacheStore cache;
  late MockCheckoutRemoteDataSource remote;
  late MockNetworkInfo networkInfo;
  late AddressRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AddressRequest());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('urbanthread_address_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('address_cache');
    cache = CacheStore(box);

    remote = MockCheckoutRemoteDataSource();
    networkInfo = MockNetworkInfo();
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);

    repository = AddressRepositoryImpl(
      remote: remote,
      cache: cache,
      networkInfo: networkInfo,
    );
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Map<String, dynamic> addressJson({
    String id = 'a1',
    String label = 'Home',
    String type = 'home',
    String fullName = 'Aarav Sharma',
    String phone = '+9779812345678',
    String street = '12 Jhamsikhel Road',
    String city = 'Lalitpur',
    String state = 'Bagmati',
    String postalCode = '44700',
    String landmark = '',
    bool isDefault = false,
  }) =>
      <String, dynamic>{
        '_id': id,
        'label': label,
        'type': type,
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': 'Nepal',
        'landmark': landmark,
        'isDefault': isDefault,
      };

  AddressModel model(Map<String, dynamic> json) => AddressModel.fromJson(json);

  const draft = AddressDraft(
    fullName: 'Aarav Sharma',
    phone: '+9779812345678',
    street: '12 Jhamsikhel Road',
    city: 'Lalitpur',
    state: 'Bagmati',
    postalCode: '44700',
  );

  /// Primes the cache the way a successful read does, so the offline and
  /// fallback paths start from a realistic entry rather than a hand-written
  /// one.
  Future<void> primeCache() async {
    when(() => remote.getAddresses()).thenAnswer(
      (_) async => envelope([
        model(addressJson(id: 'a1')),
        model(addressJson(id: 'a2', label: 'Office', isDefault: true)),
      ]),
    );
    await repository.getAddresses();
  }

  AddressRequest captureAddressRequest(void Function() call) =>
      verify(call).captured.single as AddressRequest;

  group('read — GET /addresses', () {
    test('puts the default first so the picker opens on one tap', () async {
      when(() => remote.getAddresses()).thenAnswer(
        (_) async => envelope([
          model(addressJson(id: 'a1')),
          model(addressJson(id: 'a2', label: 'Office', isDefault: true)),
        ]),
      );

      final addresses = (await repository.getAddresses()).valueOrNull!;

      expect(addresses.map((address) => address.id), ['a2', 'a1']);
      expect(addresses.first.isDefault, isTrue);
    });

    test('caches what it read', () async {
      await primeCache();

      expect(cache.has('addresses'), isTrue);
    });

    test('hands back an unmodifiable list', () async {
      await primeCache();

      final addresses = (await repository.getAddresses()).valueOrNull!;

      // Callers hold this while checkout re-reads; letting one mutate it in
      // place would desynchronise two screens off one list.
      expect(
        () => addresses.add(addresses.first),
        throwsUnsupportedError,
      );
    });

    test('serves the cached book while offline', () async {
      await primeCache();
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final addresses = (await repository.getAddresses()).valueOrNull!;

      // An address is a fact about the customer, not a claim about stock — it
      // stays true offline, and it sorts the same way coming out of the cache.
      expect(addresses.map((address) => address.id), ['a2', 'a1']);
      expect(addresses.first.city, 'Lalitpur');
      verify(() => remote.getAddresses()).called(1);
    });

    test('offline with nothing cached is an empty-cache failure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getAddresses();

      // Distinct from a cache *error*: storage worked, it is simply empty, and
      // the screen should say "not downloaded yet" rather than "unavailable".
      expect(result.failureOrNull, isA<EmptyCacheFailure>());
      verifyNever(() => remote.getAddresses());
    });

    test('a dropped connection falls back to the cache', () async {
      await primeCache();
      when(() => remote.getAddresses()).thenThrow(connectionError());

      final result = await repository.getAddresses();

      expect(result.valueOrNull?.map((address) => address.id), ['a2', 'a1']);
    });

    test('a 401 is not softened by the cache', () async {
      await primeCache();
      when(() => remote.getAddresses()).thenThrow(httpError(401));

      final result = await repository.getAddresses();

      // Serving a cached book on a dead session would hide the sign-out the
      // router needs to perform.
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });
  });

  group('create — POST /addresses', () {
    test('returns the address the server assigned an id to', () async {
      when(() => remote.addAddress(any())).thenAnswer(
        (_) async => envelope(model(addressJson(id: 'a9', isDefault: true))),
      );

      final result = await repository.addAddress(draft);

      // That id is what `POST /orders` sends as `shippingAddressId`, so it is
      // the only reason this write cannot be queued offline.
      expect(result.valueOrNull?.id, 'a9');
      expect(result.valueOrNull?.type, AddressType.home);
    });

    test('trims the draft and states isDefault explicitly', () async {
      when(() => remote.addAddress(any())).thenAnswer(
        (_) async => envelope(model(addressJson())),
      );

      await repository.addAddress(
        draft.copyWith(fullName: '  Aarav Sharma  ', city: ' Lalitpur '),
      );

      final request = captureAddressRequest(
        () => remote.addAddress(captureAny()),
      );
      expect(request.fullName, 'Aarav Sharma');
      expect(request.city, 'Lalitpur');
      expect(request.street, '12 Jhamsikhel Road');
      expect(request.type, 'home');
      expect(request.isDefault, isFalse);
    });

    test('asks for the default when the customer ticked it', () async {
      when(() => remote.addAddress(any())).thenAnswer(
        (_) async => envelope(model(addressJson(isDefault: true))),
      );

      await repository.addAddress(draft.copyWith(isDefault: true));

      expect(
        captureAddressRequest(() => remote.addAddress(captureAny())).isDefault,
        isTrue,
      );
    });

    test('invalidates the cached book, since the new entry may be the default',
        () async {
      await primeCache();
      when(() => remote.addAddress(any())).thenAnswer(
        (_) async => envelope(model(addressJson(id: 'a9', isDefault: true))),
      );

      await repository.addAddress(draft);

      // The first address a customer saves becomes their default server-side
      // whether they asked or not, so the cached copy is no longer the book.
      expect(cache.has('addresses'), isFalse);
    });

    test('refuses to write while offline, without calling the API', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.addAddress(draft);

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(
        result.failureOrNull?.message,
        'You need to be online to change your saved addresses.',
      );
      verifyNever(() => remote.addAddress(any()));
    });

    test('surfaces the validator field errors for inline messages', () async {
      when(() => remote.addAddress(any())).thenThrow(
        httpError(
          422,
          message: 'Validation failed.',
          errors: [
            {'field': 'phone', 'message': 'Enter a valid phone number.'},
          ],
        ),
      );

      final result = await repository.addAddress(draft.copyWith(phone: '123'));

      expect(
        (result.failureOrNull! as ValidationFailure).forField('phone'),
        'Enter a valid phone number.',
      );
    });
  });

  group('update — PATCH /addresses/{id}', () {
    test('never sends isDefault: false on a patch', () async {
      when(() => remote.updateAddress(any(), any())).thenAnswer(
        (_) async => envelope(model(addressJson(street: '7 Pulchowk Road'))),
      );

      final result = await repository.updateAddress(
        'a1',
        draft.copyWith(street: '7 Pulchowk Road'),
      );

      expect(result.valueOrNull?.street, '7 Pulchowk Road');
      final request = verify(
        () => remote.updateAddress('a1', captureAny()),
      ).captured.single as AddressRequest;
      // Clearing a default is done by promoting another address, so sending
      // `false` here is a no-op the server would still process. `includeIfNull`
      // keeps the key out of the body entirely.
      expect(request.isDefault, isNull);
      expect(request.toJson().containsKey('isDefault'), isFalse);
    });

    test('promotes to default when the draft says so', () async {
      when(() => remote.updateAddress(any(), any())).thenAnswer(
        (_) async => envelope(model(addressJson(isDefault: true))),
      );

      await repository.updateAddress('a1', draft.copyWith(isDefault: true));

      final request = verify(
        () => remote.updateAddress('a1', captureAny()),
      ).captured.single as AddressRequest;
      expect(request.isDefault, isTrue);
    });

    test('sends the whole address, so a cleared field is actually cleared',
        () async {
      when(() => remote.updateAddress(any(), any())).thenAnswer(
        (_) async => envelope(model(addressJson())),
      );

      await repository.updateAddress(
        'a1',
        AddressDraft.from(
          const Address(
            id: 'a1',
            fullName: 'Aarav Sharma',
            phone: '+9779812345678',
            street: '12 Jhamsikhel Road',
            city: 'Lalitpur',
            landmark: 'Behind the bakery',
          ),
        ).copyWith(landmark: ''),
      );

      final request = verify(
        () => remote.updateAddress('a1', captureAny()),
      ).captured.single as AddressRequest;
      // A partial body would leave the old landmark in place — the form edits
      // a whole address, so it sends one.
      expect(request.landmark, '');
      expect(request.toJson().containsKey('landmark'), isTrue);
    });

    test('invalidates the cached book', () async {
      await primeCache();
      when(() => remote.updateAddress(any(), any())).thenAnswer(
        (_) async => envelope(model(addressJson())),
      );

      await repository.updateAddress('a1', draft);

      expect(cache.has('addresses'), isFalse);
    });

    test('refuses to write while offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateAddress('a1', draft);

      expect(result.failureOrNull, isA<NetworkFailure>());
      verifyNever(() => remote.updateAddress(any(), any()));
    });

    test('an id that is not in this account is not found', () async {
      when(() => remote.updateAddress(any(), any())).thenThrow(
        httpError(404, message: 'Address not found.'),
      );

      final result = await repository.updateAddress('a-other', draft);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('delete — DELETE /addresses/{id}', () {
    test('reports success on a 204 and drops the cached book', () async {
      await primeCache();
      when(() => remote.deleteAddress('a1')).thenAnswer((_) async {});

      final result = await repository.deleteAddress('a1');

      expect(result.isSuccess, isTrue);
      expect(cache.has('addresses'), isFalse);
      verify(() => remote.deleteAddress('a1')).called(1);
    });

    test('refuses to delete while offline, without calling the API', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.deleteAddress('a1');

      expect(result.failureOrNull, isA<NetworkFailure>());
      verifyNever(() => remote.deleteAddress(any()));
    });

    test('an already-deleted address is not found', () async {
      when(() => remote.deleteAddress(any())).thenThrow(
        httpError(404, message: 'Address not found.'),
      );

      final result = await repository.deleteAddress('gone');

      expect(result.failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('promote — PATCH /addresses/{id}/default', () {
    test('replaces the whole book from the response', () async {
      when(() => remote.setDefaultAddress('a1')).thenAnswer(
        (_) async => envelope([
          model(addressJson(id: 'a1', isDefault: true)),
          model(addressJson(id: 'a2', label: 'Office')),
        ]),
      );

      final addresses = (await repository.setDefaultAddress('a1')).valueOrNull!;

      // Taking the whole book is the only way to avoid briefly showing two
      // defaults — the previous one had its flag cleared server-side.
      expect(addresses.map((address) => address.id), ['a1', 'a2']);
      expect(addresses.first.isDefault, isTrue);
      expect(addresses.last.isDefault, isFalse);
    });

    test('re-caches the promoted book rather than invalidating it', () async {
      when(() => remote.setDefaultAddress('a1')).thenAnswer(
        (_) async => envelope([model(addressJson(id: 'a1', isDefault: true))]),
      );

      await repository.setDefaultAddress('a1');
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final offline = (await repository.getAddresses()).valueOrNull!;

      expect(offline.single.id, 'a1');
      expect(offline.single.isDefault, isTrue);
    });

    test('refuses while offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.setDefaultAddress('a1');

      expect(result.failureOrNull, isA<NetworkFailure>());
      verifyNever(() => remote.setDefaultAddress(any()));
    });
  });
}
