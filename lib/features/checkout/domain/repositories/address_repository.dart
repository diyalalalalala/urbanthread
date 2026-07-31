import '../../../../core/domain/result.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/address_draft.dart';

abstract interface class AddressRepository {
  Future<Result<List<Address>>> getAddresses();

  Future<Result<Address>> addAddress(AddressDraft draft);

  Future<Result<Address>> updateAddress(String id, AddressDraft draft);

  Future<Result<void>> deleteAddress(String id);

  Future<Result<List<Address>>> setDefaultAddress(String id);
}
