import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

class AddToCartParams {
  const AddToCartParams({
    required this.productId,
    required this.variantId,
    this.quantity = 1,
  });

  final String productId;

  /// Required: the API has no notion of adding a product without picking a
  /// colour/size combination, because stock is tracked per variant.
  final String variantId;

  final int quantity;
}

/// Adds a variant to the cart.
///
/// This is the entry point other features (product detail, product cards,
/// search results) should call — never the repository directly.
class AddToCartUseCase extends UseCase<CartSnapshot, AddToCartParams> {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(AddToCartParams params) =>
      _repository.addItem(
        productId: params.productId,
        variantId: params.variantId,
        quantity: params.quantity,
      );
}
