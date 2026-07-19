import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/checkout_cart.dart';
import '../repositories/checkout_repository.dart';

/// Asks the server whether this basket can become an order.
///
/// Run when checkout opens and again immediately before placing, because
/// stock can be taken by another shopper in between — the second call is
/// cheap and turns a rolled-back order into a fixable message.
class ValidateCartUseCase extends UseCase<CheckoutCart, NoParams> {
  const ValidateCartUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<CheckoutCart>> call(NoParams params) =>
      _repository.validateCart();
}
