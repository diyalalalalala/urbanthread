import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/cart_models.dart';

part 'cart_remote_datasource.g.dart';

/// Typed HTTP surface for `/cart`.
///
/// Note how uniform the return type is: every mutating route answers with the
/// full `{cart, notices, summary}` triple, so a write is a complete state
/// replacement and the caller never has to follow up with a read. The two
/// exceptions are `/cart/summary` (totals alone) and `/cart/validate`.
///
/// Paths with a parameter are written as literals rather than through
/// [ApiEndpoints] builders because Retrofit needs the `{placeholder}` form at
/// compile time; the constants file still documents them.
@RestApi()
abstract class CartRemoteDataSource {
  factory CartRemoteDataSource(Dio dio, {String baseUrl}) =
      _CartRemoteDataSource;

  @GET(ApiEndpoints.cart)
  Future<ApiEnvelope<CartSnapshotModel>> getCart();

  /// Returns *only* the summary object — not the triple.
  @GET(ApiEndpoints.cartSummary)
  Future<ApiEnvelope<CartSummaryModel>> getSummary();

  /// 200 when the cart is ready to check out; 422 listing every blocker at
  /// once when it is not.
  @GET(ApiEndpoints.cartValidate)
  Future<ApiEnvelope<CartValidationModel>> validate();

  /// Answers **201**, not 200.
  @POST(ApiEndpoints.cartItems)
  Future<ApiEnvelope<CartSnapshotModel>> addItem(
    @Body() AddCartItemRequest request,
  );

  @PATCH('/cart/items/{itemId}')
  Future<ApiEnvelope<CartSnapshotModel>> updateItem(
    @Path('itemId') String itemId,
    @Body() UpdateCartItemRequest request,
  );

  @DELETE('/cart/items/{itemId}')
  Future<ApiEnvelope<CartSnapshotModel>> removeItem(
    @Path('itemId') String itemId,
  );

  @POST('/cart/items/{itemId}/save-for-later')
  Future<ApiEnvelope<CartSnapshotModel>> saveForLater(
    @Path('itemId') String itemId,
  );

  @POST('/cart/items/{itemId}/move-to-cart')
  Future<ApiEnvelope<CartSnapshotModel>> moveToCart(
    @Path('itemId') String itemId,
  );

  @POST(ApiEndpoints.cartCoupon)
  Future<ApiEnvelope<CartSnapshotModel>> applyCoupon(
    @Body() ApplyCouponRequest request,
  );

  @DELETE(ApiEndpoints.cartCoupon)
  Future<ApiEnvelope<CartSnapshotModel>> removeCoupon();

  @DELETE(ApiEndpoints.cart)
  Future<ApiEnvelope<CartSnapshotModel>> clearCart();
}
