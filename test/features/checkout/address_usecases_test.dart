import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/domain/result.dart';
import 'package:urbanthread/core/domain/usecase.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/features/authentication/domain/entities/user.dart';
import 'package:urbanthread/features/checkout/domain/entities/address_draft.dart';
import 'package:urbanthread/features/checkout/domain/repositories/address_repository.dart';
import 'package:urbanthread/features/checkout/domain/usecases/add_address_usecase.dart';
import 'package:urbanthread/features/checkout/domain/usecases/delete_address_usecase.dart';
import 'package:urbanthread/features/checkout/domain/usecases/get_addresses_usecase.dart';
import 'package:urbanthread/features/checkout/domain/usecases/set_default_address_usecase.dart';
import 'package:urbanthread/features/checkout/domain/usecases/update_address_usecase.dart';

class MockAddressRepository extends Mock implements AddressRepository {}

/// The CRUD use cases for an address, plus the draft that carries a write.
///
/// [AddressDraft] is the interesting half: it is the only place that knows the
/// backend's required fields, and checkout disables its submit button off that
/// knowledge rather than round-tripping for a 422 it could have predicted.
void main() {
  const home = Address(
    id: 'a1',
    fullName: 'Aarav Sharma',
    phone: '+9779812345678',
    street: '12 Jhamsikhel Road',
    city: 'Lalitpur',
    state: 'Bagmati',
    postalCode: '44700',
    landmark: 'Behind the bakery',
    isDefault: true,
  );
  const office = Address(
    id: 'a2',
    label: 'Office',
    type: AddressType.office,
    fullName: 'Aarav Sharma',
    phone: '+9779812345678',
    street: '4 Pulchowk',
    city: 'Lalitpur',
  );
  const draft = AddressDraft(
    fullName: 'Aarav Sharma',
    phone: '+9779812345678',
    street: '12 Jhamsikhel Road',
    city: 'Lalitpur',
  );

  late MockAddressRepository repository;

  setUpAll(() => registerFallbackValue(draft));

  setUp(() => repository = MockAddressRepository());

  group('GetAddressesUseCase', () {
    test('returns the book as the repository ordered it', () async {
      when(() => repository.getAddresses())
          .thenAnswer((_) async => const Result.success([home, office]));

      final result = await GetAddressesUseCase(repository)(const NoParams());

      expect(result.valueOrNull, [home, office]);
    });

    test('passes an offline failure straight through', () async {
      when(() => repository.getAddresses())
          .thenAnswer((_) async => const Result.failure(EmptyCacheFailure()));

      final result = await GetAddressesUseCase(repository)(const NoParams());

      expect(result.failureOrNull, isA<EmptyCacheFailure>());
    });
  });

  group('AddAddressUseCase', () {
    test('takes the draft as its whole parameter', () async {
      when(() => repository.addAddress(any()))
          .thenAnswer((_) async => const Result.success(home));

      final result = await AddAddressUseCase(repository)(draft);

      expect(result.valueOrNull, home);
      verify(() => repository.addAddress(draft)).called(1);
    });
  });

  group('UpdateAddressUseCase', () {
    test('pairs the id with the draft', () async {
      when(() => repository.updateAddress(any(), any()))
          .thenAnswer((_) async => const Result.success(home));

      await UpdateAddressUseCase(repository)(
        const UpdateAddressParams(id: 'a1', draft: draft),
      );

      verify(() => repository.updateAddress('a1', draft)).called(1);
    });
  });

  group('DeleteAddressUseCase', () {
    test('takes the id as its whole parameter', () async {
      when(() => repository.deleteAddress(any()))
          .thenAnswer((_) async => const Result.success(null));

      final result = await DeleteAddressUseCase(repository)('a1');

      expect(result.isSuccess, isTrue);
      verify(() => repository.deleteAddress('a1')).called(1);
    });
  });

  group('SetDefaultAddressUseCase', () {
    test('returns the whole book, not the promoted entry', () async {
      when(() => repository.setDefaultAddress(any()))
          .thenAnswer((_) async => const Result.success([home, office]));

      final result = await SetDefaultAddressUseCase(repository)('a1');

      // A caller holding a single updated entry would render two defaults
      // until the next read.
      expect(result.valueOrNull, hasLength(2));
      verify(() => repository.setDefaultAddress('a1')).called(1);
    });
  });

  group('AddressDraft', () {
    test('is complete only with the four fields the backend requires', () {
      expect(draft.isComplete, isTrue);
      expect(draft.copyWith(fullName: 'A').isComplete, isFalse);
      expect(draft.copyWith(phone: '  ').isComplete, isFalse);
      expect(draft.copyWith(street: '').isComplete, isFalse);
      expect(draft.copyWith(city: '   ').isComplete, isFalse);
    });

    test('defaults match the API defaults', () {
      // The picker shows these before the customer touches the form, so a
      // mismatch here is a silently wrong address rather than an error.
      expect(draft.label, 'Home');
      expect(draft.type, AddressType.home);
      expect(draft.country, 'Nepal');
      expect(draft.isDefault, isFalse);
    });

    test('pre-fills every editable field when editing an existing entry', () {
      final editing = AddressDraft.from(home);

      expect(editing.fullName, home.fullName);
      expect(editing.phone, home.phone);
      expect(editing.street, home.street);
      expect(editing.city, home.city);
      expect(editing.state, home.state);
      expect(editing.postalCode, home.postalCode);
      expect(editing.landmark, home.landmark);
      expect(editing.country, home.country);
      expect(editing.type, home.type);
      expect(editing.isDefault, isTrue);
    });

    test('carries the office type onto the wire value the API expects', () {
      expect(AddressDraft.from(office).type.wireValue, 'office');
      expect(AddressType.parse('OFFICE'), AddressType.office);
      // Anything unrecognised falls back to home rather than throwing on a
      // value a future backend release might add.
      expect(AddressType.parse(null), AddressType.home);
      expect(AddressType.parse('warehouse'), AddressType.home);
    });
  });

  group('Address', () {
    test('renders a single line without the empty optional parts', () {
      expect(
        home.singleLine,
        '12 Jhamsikhel Road, Behind the bakery, Lalitpur, Bagmati, 44700, '
            'Nepal',
      );
      // `state`, `postalCode` and `landmark` all default to `""` on the wire,
      // and a joined-with-commas line would show the gaps.
      expect(office.singleLine, '4 Pulchowk, Lalitpur, Nepal');
    });
  });
}
