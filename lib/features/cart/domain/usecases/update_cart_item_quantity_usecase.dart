import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantityParams {
  const UpdateCartItemQuantityParams({
    required this.itemId,
    required this.quantity,
  });

  final String itemId;

  final int quantity;
}

class UpdateCartItemQuantityUseCase
    extends UseCase<CartSnapshot, UpdateCartItemQuantityParams> {
  const UpdateCartItemQuantityUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(UpdateCartItemQuantityParams params) =>
      _repository.updateQuantity(
        itemId: params.itemId,
        quantity: params.quantity,
      );
}
