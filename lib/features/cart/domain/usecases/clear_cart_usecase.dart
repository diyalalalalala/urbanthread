import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

/// Empties the cart, including saved-for-later lines and any coupon.
class ClearCartUseCase extends UseCase<CartSnapshot, NoParams> {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(NoParams params) =>
      _repository.clearCart();
}
