import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

/// Un-parks a saved line.
///
/// Unlike saving, this can fail: the server re-checks stock and refreshes the
/// price snapshot on the way back, so an item saved months ago may no longer
/// be purchasable at the quantity that was parked.
class MoveToCartUseCase extends UseCase<CartSnapshot, String> {
  const MoveToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(String itemId) =>
      _repository.moveToCart(itemId);
}
