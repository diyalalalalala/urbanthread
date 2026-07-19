import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/address_draft.dart';
import '../repositories/address_repository.dart';

/// Saves a new address. Reachable from inside checkout, because a customer
/// with no saved address cannot otherwise proceed — `POST /orders` needs an
/// id from the book, and there is no way to pass a one-off address.
class AddAddressUseCase extends UseCase<Address, AddressDraft> {
  const AddAddressUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<Address>> call(AddressDraft params) =>
      _repository.addAddress(params);
}
