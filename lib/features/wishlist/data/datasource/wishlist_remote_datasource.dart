import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/wishlist_models.dart';

part 'wishlist_remote_datasource.g.dart';

@RestApi()
abstract class WishlistRemoteDataSource {
  factory WishlistRemoteDataSource(Dio dio, {String baseUrl}) =
      _WishlistRemoteDataSource;

  @GET(ApiEndpoints.wishlist)
  Future<ApiEnvelope<WishlistModel>> getWishlist();

  @POST(ApiEndpoints.wishlist)
  Future<ApiEnvelope<WishlistModel>> addItem(
    @Body() AddWishlistItemRequest request,
  );

  @DELETE(ApiEndpoints.wishlist)
  Future<ApiEnvelope<WishlistModel>> clear();

  @DELETE('/wishlist/{productId}')
  Future<ApiEnvelope<WishlistModel>> removeItem(
    @Path('productId') String productId,
  );

  @POST('/wishlist/{productId}/move-to-cart')
  Future<ApiEnvelope<WishlistMoveResultModel>> moveToCart(
    @Path('productId') String productId,
    @Body() WishlistMoveToCartRequest request,
  );

  @GET('/wishlist/{productId}/check')
  Future<ApiEnvelope<WishlistCheckModel>> check(
    @Path('productId') String productId,
  );
}
