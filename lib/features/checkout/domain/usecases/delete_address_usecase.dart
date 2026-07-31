import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/address_repository.dart';

class DeleteAddressUseCase extends UseCase<void, String> {
  const DeleteAddressUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<void>> call(String params) =>
      _repository.deleteAddress(params);
}
