import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/coupon.dart';
import '../repositories/checkout_repository.dart';

class GetAvailableCouponsUseCase extends UseCase<List<AvailableCoupon>, double> {
  const GetAvailableCouponsUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<List<AvailableCoupon>>> call(double params) =>
      _repository.getAvailableCoupons(params);
}
