import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/checkout_models.dart';

part 'checkout_remote_datasource.g.dart';

@RestApi()
abstract class CheckoutRemoteDataSource {
  factory CheckoutRemoteDataSource(Dio dio, {String baseUrl}) =
      _CheckoutRemoteDataSource;

  @GET(ApiEndpoints.cartValidate)
  Future<ApiEnvelope<CartValidationModel>> validateCart();

  @GET(ApiEndpoints.cartSummary)
  Future<ApiEnvelope<CartSummaryModel>> getCartSummary();

  @GET(ApiEndpoints.availableCoupons)
  Future<ApiEnvelope<List<AvailableCouponModel>>> getAvailableCoupons(
    @Query('subtotal') double subtotal,
  );

  @POST(ApiEndpoints.validateCoupon)
  Future<ApiEnvelope<CouponPreviewModel>> validateCoupon(
    @Body() ValidateCouponRequest request,
  );

  @GET(ApiEndpoints.addresses)
  Future<ApiEnvelope<List<AddressModel>>> getAddresses();

  @POST(ApiEndpoints.addresses)
  Future<ApiEnvelope<AddressModel>> addAddress(@Body() AddressRequest request);

  @PATCH('/addresses/{id}')
  Future<ApiEnvelope<AddressModel>> updateAddress(
    @Path('id') String id,
    @Body() AddressRequest request,
  );

  @DELETE('/addresses/{id}')
  Future<void> deleteAddress(@Path('id') String id);

  @PATCH('/addresses/{id}/default')
  Future<ApiEnvelope<List<AddressModel>>> setDefaultAddress(
    @Path('id') String id,
  );
}
