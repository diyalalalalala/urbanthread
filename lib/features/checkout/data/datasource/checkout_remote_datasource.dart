import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/checkout_models.dart';

part 'checkout_remote_datasource.g.dart';

/// The endpoints checkout reads, across three route families.
///
/// The cart routes are declared here rather than borrowed from the cart
/// feature on purpose: checkout needs exactly two reads out of that module,
/// and owning them keeps the two features independently buildable. Cart
/// *mutation* stays where it belongs — nothing here changes the basket.
///
/// [AddressModel] is reused from the authentication feature. The address book
/// is the same data whether it is read off the user document at login or
/// managed through `/addresses`, and a parallel model would be one more place
/// for `street` to be misspelled as `line1`.
@RestApi()
abstract class CheckoutRemoteDataSource {
  factory CheckoutRemoteDataSource(Dio dio, {String baseUrl}) =
      _CheckoutRemoteDataSource;

  // ── Cart ─────────────────────────────────────────────────────────────

  /// The pre-flight gate. 200 means orderable; anything wrong is a 422
  /// carrying one `errors[]` entry per blocker.
  @GET(ApiEndpoints.cartValidate)
  Future<ApiEnvelope<CartValidationModel>> validateCart();

  @GET(ApiEndpoints.cartSummary)
  Future<ApiEnvelope<CartSummaryModel>> getCartSummary();

  // ── Coupons ──────────────────────────────────────────────────────────

  /// Already filtered to codes this account has not used up. `subtotal`
  /// drives `isApplicable`, `estimatedDiscount` and `amountToQualify`.
  @GET(ApiEndpoints.availableCoupons)
  Future<ApiEnvelope<List<AvailableCouponModel>>> getAvailableCoupons(
    @Query('subtotal') double subtotal,
  );

  @POST(ApiEndpoints.validateCoupon)
  Future<ApiEnvelope<CouponPreviewModel>> validateCoupon(
    @Body() ValidateCouponRequest request,
  );

  // ── Address book ─────────────────────────────────────────────────────

  @GET(ApiEndpoints.addresses)
  Future<ApiEnvelope<List<AddressModel>>> getAddresses();

  @POST(ApiEndpoints.addresses)
  Future<ApiEnvelope<AddressModel>> addAddress(@Body() AddressRequest request);

  @PATCH('/addresses/{id}')
  Future<ApiEnvelope<AddressModel>> updateAddress(
    @Path('id') String id,
    @Body() AddressRequest request,
  );

  /// Answers **204 with no body**, so there is no envelope to decode — hence
  /// `void` rather than `ApiEnvelope<dynamic>`, which would fail on the empty
  /// response.
  @DELETE('/addresses/{id}')
  Future<void> deleteAddress(@Path('id') String id);

  /// Returns the **entire** address book, not the one promoted entry: setting
  /// a default clears the flag on the previous one, so every row may differ.
  @PATCH('/addresses/{id}/default')
  Future<ApiEnvelope<List<AddressModel>>> setDefaultAddress(
    @Path('id') String id,
  );
}
