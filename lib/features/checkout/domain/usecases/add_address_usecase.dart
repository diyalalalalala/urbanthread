import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/address_draft.dart';
import '../repositories/address_repository.dart';

class AddAddressUseCase extends UseCase<Address, AddressDraft> {
  const AddAddressUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<Address>> call(AddressDraft params) =>
      _repository.addAddress(params);
}
