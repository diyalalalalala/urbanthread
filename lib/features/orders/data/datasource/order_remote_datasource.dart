import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/order_model.dart';

part 'order_remote_datasource.g.dart';

/// Typed HTTP surface for `/orders`.
///
/// Only the customer-facing routes are declared. The admin ones
/// (`PATCH /:id/status`, the refund and return-resolution endpoints) are
/// deliberately absent — this is the customer app and they would answer 403.
@RestApi()
abstract class OrderRemoteDataSource {
  factory OrderRemoteDataSource(Dio dio, {String baseUrl}) =
      _OrderRemoteDataSource;

  /// Checkout. Settles synchronously inside a server-side transaction, so the
  /// order that comes back is already in its final state — `pending` for cash
  /// on delivery, `confirmed`/`paid` for the mock gateway.
  @POST(ApiEndpoints.orders)
  Future<ApiEnvelope<OrderModel>> placeOrder(@Body() PlaceOrderRequest request);

  /// The customer's history. Paginated, always newest-first — the sort is
  /// fixed server-side and no `sort` parameter is accepted.
  ///
  /// These rows are lean, so `totalItems`, `isCancellable` and `isTerminal`
  /// are missing from every one of them.
  @GET(ApiEndpoints.myOrders)
  Future<ApiEnvelope<List<OrderModel>>> getMyOrders(
    @Queries() Map<String, dynamic> query,
  );

  @GET('/orders/{id}')
  Future<ApiEnvelope<OrderModel>> getOrderById(@Path('id') String id);

  /// Looked up by the `UT-YYYYMMDD-NNNN` reference. The backend matches that
  /// shape in a validator, so a malformed number is a 422, not a 404.
  @GET('/orders/number/{orderNumber}')
  Future<ApiEnvelope<OrderModel>> getOrderByNumber(
    @Path('orderNumber') String orderNumber,
  );

  /// A narrow projection — timeline and courier details, no prices and no
  /// address — so it does not decode into [OrderModel].
  @GET('/orders/{id}/track')
  Future<ApiEnvelope<OrderTrackingModel>> trackOrder(@Path('id') String id);

  @PATCH('/orders/{id}/cancel')
  Future<ApiEnvelope<OrderModel>> cancelOrder(
    @Path('id') String id,
    @Body() CancelOrderRequest request,
  );

  @POST('/orders/{id}/return')
  Future<ApiEnvelope<OrderModel>> requestReturn(
    @Path('id') String id,
    @Body() ReturnRequestBody request,
  );
}
