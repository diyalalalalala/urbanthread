import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/coupon.dart';
import '../repositories/checkout_repository.dart';

class ValidateCouponParams {
  const ValidateCouponParams({required this.code, this.subtotal});

  final String code;
  final double? subtotal;
}

/// Checks a typed-in code before committing to it.
class ValidateCouponUseCase extends UseCase<CouponPreview, ValidateCouponParams> {
  const ValidateCouponUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<CouponPreview>> call(ValidateCouponParams params) =>
      _repository.validateCoupon(code: params.code, subtotal: params.subtotal);
}
