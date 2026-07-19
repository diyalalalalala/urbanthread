import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/domain/entities/user.dart';
import '../repositories/address_repository.dart';

/// The address book, for the checkout picker.
class GetAddressesUseCase extends UseCase<List<Address>, NoParams> {
  const GetAddressesUseCase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<List<Address>>> call(NoParams params) =>
      _repository.getAddresses();
}
