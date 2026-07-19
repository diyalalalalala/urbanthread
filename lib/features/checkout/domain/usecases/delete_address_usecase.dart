import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/address_repository.dart';

/// Removes an address from the book.
///
/// Safe to do after ordering: an order carries its own immutable snapshot of
/// the delivery address, so nothing already placed changes.
class DeleteAddressUseCase extends UseCase<void, String> {
  const DeleteAddressUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<void>> call(String params) =>
      _repository.deleteAddress(params);
}
