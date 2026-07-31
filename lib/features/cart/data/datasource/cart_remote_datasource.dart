import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/cart_models.dart';

part 'cart_remote_datasource.g.dart';

@RestApi()
abstract class CartRemoteDataSource {
  factory CartRemoteDataSource(Dio dio, {String baseUrl}) =
      _CartRemoteDataSource;

  @GET(ApiEndpoints.cart)
  Future<ApiEnvelope<CartSnapshotModel>> getCart();

  @GET(ApiEndpoints.cartSummary)
  Future<ApiEnvelope<CartSummaryModel>> getSummary();

  @GET(ApiEndpoints.cartValidate)
  Future<ApiEnvelope<CartValidationModel>> validate();

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
