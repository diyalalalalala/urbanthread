import '../../../../core/domain/result.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/address_draft.dart';

/// The signed-in customer's address book.
///
/// It lives in the checkout feature because checkout is the only thing that
/// needs it as more than a display list: `POST /orders` takes a
/// `shippingAddressId`, so choosing — and often creating — an address is a
/// step of placing an order, not a detour into account settings.
abstract interface class AddressRepository {
  /// Every saved address, default first.
  Future<Result<List<Address>>> getAddresses();

  /// Creates one. The first address a customer saves becomes their default
  /// server-side whether or not [AddressDraft.isDefault] was set.
  Future<Result<Address>> addAddress(AddressDraft draft);

  /// Partial update — only the fields the draft changed need be meaningful,
  /// though the API tolerates the whole object.
  Future<Result<Address>> updateAddress(String id, AddressDraft draft);

  /// Removes an address. Answers 204 with no body.
  ///
  /// Deleting one already referenced by an order is harmless: orders embed
  /// their own immutable snapshot of where the parcel went.
  Future<Result<void>> deleteAddress(String id);

  /// Promotes an address to the default.
  ///
  /// Returns the **whole book**, not the one address — the server has to
  /// clear the flag on the previous default, so every entry may have changed
  /// and the caller should replace its list wholesale.
  Future<Result<List<Address>>> setDefaultAddress(String id);
}
