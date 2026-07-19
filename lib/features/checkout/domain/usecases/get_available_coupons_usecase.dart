import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/coupon.dart';
import '../repositories/checkout_repository.dart';

/// Offers the customer the codes they could use, rather than making them
/// know one. Scored against the current subtotal so the list can say "spend
/// Rs 400 more" instead of silently hiding a near miss.
class GetAvailableCouponsUseCase extends UseCase<List<AvailableCoupon>, double> {
  const GetAvailableCouponsUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<List<AvailableCoupon>>> call(double params) =>
      _repository.getAvailableCoupons(params);
}
