import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) =
      _AuthRemoteDataSource;

  @POST(ApiEndpoints.register)
  Future<ApiEnvelope<AuthResponseModel>> register(
    @Body() RegisterRequest request,
  );

  @POST(ApiEndpoints.login)
  Future<ApiEnvelope<AuthResponseModel>> login(@Body() LoginRequest request);

  @POST(ApiEndpoints.logout)
  Future<ApiEnvelope<dynamic>> logout();

  @POST(ApiEndpoints.logoutAll)
  Future<ApiEnvelope<dynamic>> logoutAll();

  @GET(ApiEndpoints.me)
  Future<ApiEnvelope<UserModel>> getCurrentUser();

  @POST(ApiEndpoints.forgotPassword)
  Future<ApiEnvelope<dynamic>> forgotPassword(@Body() EmailRequest request);

  @POST('/auth/reset-password/{token}')
  Future<ApiEnvelope<dynamic>> resetPassword(
    @Path('token') String token,
    @Body() ResetPasswordRequest request,
  );

  @PATCH(ApiEndpoints.changePassword)
  Future<ApiEnvelope<UserModel>> changePassword(
    @Body() ChangePasswordRequest request,
  );
}
