import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/checkout_cart.dart';
import '../repositories/checkout_repository.dart';

/// Re-reads just the totals, after a coupon changed them.
class GetCartSummaryUseCase extends UseCase<CartSummary, NoParams> {
  const GetCartSummaryUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<CartSummary>> call(NoParams params) =>
      _repository.getCartSummary();
}
