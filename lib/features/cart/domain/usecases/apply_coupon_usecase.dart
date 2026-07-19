import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

/// Attaches a coupon code to the cart.
///
/// The stored discount is for display only — the summary re-validates the code
/// on every read, and checkout recomputes it again, so a code that expires
/// while the cart sits idle drops to zero rather than being honoured.
class ApplyCouponUseCase extends UseCase<CartSnapshot, String> {
  const ApplyCouponUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(String code) =>
      _repository.applyCoupon(code);
}
