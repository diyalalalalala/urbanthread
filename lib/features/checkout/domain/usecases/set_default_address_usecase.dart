import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/domain/entities/user.dart';
import '../repositories/address_repository.dart';

class SetDefaultAddressUseCase extends UseCase<List<Address>, String> {
  const SetDefaultAddressUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<List<Address>>> call(String params) =>
      _repository.setDefaultAddress(params);
}
