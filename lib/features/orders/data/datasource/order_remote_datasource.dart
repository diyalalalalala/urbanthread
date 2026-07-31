import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/order_model.dart';

part 'order_remote_datasource.g.dart';

@RestApi()
abstract class OrderRemoteDataSource {
  factory OrderRemoteDataSource(Dio dio, {String baseUrl}) =
      _OrderRemoteDataSource;

  @POST(ApiEndpoints.orders)
  Future<ApiEnvelope<OrderModel>> placeOrder(@Body() PlaceOrderRequest request);

  @GET(ApiEndpoints.myOrders)
  Future<ApiEnvelope<List<OrderModel>>> getMyOrders(
    @Queries() Map<String, dynamic> query,
  );

  @GET('/orders/{id}')
  Future<ApiEnvelope<OrderModel>> getOrderById(@Path('id') String id);

  @GET('/orders/number/{orderNumber}')
  Future<ApiEnvelope<OrderModel>> getOrderByNumber(
    @Path('orderNumber') String orderNumber,
  );

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
