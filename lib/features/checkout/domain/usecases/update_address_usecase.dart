import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/address_draft.dart';
import '../repositories/address_repository.dart';

class UpdateAddressParams {
  const UpdateAddressParams({required this.id, required this.draft});

  final String id;
  final AddressDraft draft;
}

class UpdateAddressUseCase extends UseCase<Address, UpdateAddressParams> {
  const UpdateAddressUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<Address>> call(UpdateAddressParams params) =>
      _repository.updateAddress(params.id, params.draft);
}
