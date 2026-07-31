import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/checkout_cart.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasource/checkout_remote_datasource.dart';
import '../models/checkout_models.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl({
    required CheckoutRemoteDataSource remote,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _networkInfo = networkInfo;

  static const _offline = NetworkFailure(
    'Checkout needs a live connection — stock and prices are confirmed as you '
    'order. Reconnect and try again.',
  );

  final CheckoutRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<CheckoutCart>> validateCart() async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offline);
    }

    try {
      final envelope = await _remote.validateCart();
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<CartSummary>> getCartSummary() async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offline);
    }

    try {
      final envelope = await _remote.getCartSummary();
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<List<AvailableCoupon>>> getAvailableCoupons(
    double subtotal,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offline);
    }

    try {
      final envelope = await _remote.getAvailableCoupons(subtotal);
      return Result.success(
        envelope.data
            .map((coupon) => coupon.toEntity())
            .toList(growable: false),
      );
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<CouponPreview>> validateCoupon({
    required String code,
    double? subtotal,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offline);
    }

    try {
      final envelope = await _remote.validateCoupon(
        ValidateCouponRequest(
          code: code.trim().toUpperCase(),
          subtotal: subtotal,
        ),
      );
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }
}
