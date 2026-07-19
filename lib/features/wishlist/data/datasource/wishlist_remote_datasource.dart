import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/wishlist_models.dart';

part 'wishlist_remote_datasource.g.dart';

/// Typed HTTP surface for `/wishlist`.
///
/// Two things to keep straight against the cart's routes: the mutation paths
/// take a **product** id rather than a line id, and adding answers **200**
/// rather than the 201 a create normally would — because the operation is
/// idempotent, not a create.
@RestApi()
abstract class WishlistRemoteDataSource {
  factory WishlistRemoteDataSource(Dio dio, {String baseUrl}) =
      _WishlistRemoteDataSource;

  @GET(ApiEndpoints.wishlist)
  Future<ApiEnvelope<WishlistModel>> getWishlist();

  /// Idempotent: saving a product already saved returns the unchanged
  /// wishlist rather than a 409.
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

  /// Returns `{cart, wishlist}` with the cart nested as its own triple.
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
