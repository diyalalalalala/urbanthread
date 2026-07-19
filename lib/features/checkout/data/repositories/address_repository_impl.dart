import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../domain/entities/address_draft.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasource/checkout_remote_datasource.dart';
import '../models/checkout_models.dart';

/// The address book, cached for reading.
///
/// Unlike the rest of checkout this *is* worth caching: an address is a fact
/// about the customer, not a claim about stock, so a saved copy stays true
/// while offline. Writes are never queued though — the id the server assigns
/// is what `POST /orders` needs, and an address that exists only on the
/// device has no id to send.
class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl({
    required CheckoutRemoteDataSource remote,
    required CacheStore cache,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _cache = cache,
        _networkInfo = networkInfo;

  static const _cacheKey = 'addresses';

  static const _offlineWrite = NetworkFailure(
    'You need to be online to change your saved addresses.',
  );

  final CheckoutRemoteDataSource _remote;
  final CacheStore _cache;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<Address>>> getAddresses() async {
    if (!await _networkInfo.isConnected) return _cached();

    try {
      final envelope = await _remote.getAddresses();
      await _write(envelope.data);
      return Result.success(_toEntities(envelope.data));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _cached();
        if (cached.isSuccess) return cached;
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<Address>> addAddress(AddressDraft draft) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offlineWrite);
    }

    try {
      final envelope = await _remote.addAddress(_requestOf(draft, partial: false));
      // The new entry may have become the default — the first address always
      // does — so the cached list is no longer a safe copy of the book.
      await _cache.delete(_cacheKey);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<Address>> updateAddress(String id, AddressDraft draft) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offlineWrite);
    }

    try {
      final envelope = await _remote.updateAddress(
        id,
        _requestOf(draft, partial: true),
      );
      await _cache.delete(_cacheKey);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offlineWrite);
    }

    try {
      await _remote.deleteAddress(id);
      await _cache.delete(_cacheKey);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<List<Address>>> setDefaultAddress(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offlineWrite);
    }

    try {
      // The response is the whole book, already re-flagged. Taking it
      // wholesale is the only way to avoid briefly showing two defaults.
      final envelope = await _remote.setDefaultAddress(id);
      await _write(envelope.data);
      return Result.success(_toEntities(envelope.data));
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Builds the request body.
  ///
  /// On update every field is optional server-side, but sending the complete
  /// draft is still correct — the form edits a whole address, and a partial
  /// body would leave a cleared `landmark` at its old value. The flag exists
  /// so a future field-level edit can send less without changing the shape.
  AddressRequest _requestOf(AddressDraft draft, {required bool partial}) =>
      AddressRequest(
        label: draft.label.trim(),
        type: draft.type.wireValue,
        fullName: draft.fullName.trim(),
        phone: draft.phone.trim(),
        street: draft.street.trim(),
        city: draft.city.trim(),
        state: draft.state.trim(),
        postalCode: draft.postalCode.trim(),
        country: draft.country.trim(),
        landmark: draft.landmark.trim(),
        // Never send `isDefault: false` on an update — it is a no-op the
        // server would still process, and clearing a default is done by
        // promoting another address, not by unsetting this one.
        isDefault: draft.isDefault ? true : (partial ? null : false),
      );

  List<Address> _toEntities(List<AddressModel> models) {
    final addresses =
        models.map((model) => model.toEntity()).toList(growable: true);
    // Default first, then stable. The picker opens on the first row, so this
    // is what makes the common case a single tap.
    addresses.sort((a, b) {
      if (a.isDefault == b.isDefault) return 0;
      return a.isDefault ? -1 : 1;
    });
    return List.unmodifiable(addresses);
  }

  Future<void> _write(List<AddressModel> models) => _cache.write(
        _cacheKey,
        models.map((model) => model.toJson()).toList(growable: false),
      );

  Result<List<Address>> _cached() {
    final models = _cache.readList(
      _cacheKey,
      (json) => AddressModel.fromJson(Map<String, dynamic>.from(json! as Map)),
    );
    return models.isEmpty
        ? const Result.failure(EmptyCacheFailure())
        : Result.success(_toEntities(models));
  }
}
