import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

/// Typed HTTP surface for `/auth`.
///
/// Every method returns the [ApiEnvelope] rather than the payload, because
/// the backend's `message` is often the only human-readable part of a
/// response — `forgot-password` and `resend-verification` deliberately return
/// no data and answer with a deliberately vague message the UI should show
/// verbatim rather than invent its own.
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

  /// Invalidates every token for this account by bumping `tokenVersion`.
  @POST(ApiEndpoints.logoutAll)
  Future<ApiEnvelope<dynamic>> logoutAll();

  @GET(ApiEndpoints.me)
  Future<ApiEnvelope<UserModel>> getCurrentUser();

  @POST('/auth/verify-email/{token}')
  Future<ApiEnvelope<UserModel>> verifyEmail(@Path('token') String token);

  @POST(ApiEndpoints.resendVerification)
  Future<ApiEnvelope<dynamic>> resendVerification(@Body() EmailRequest request);

  @POST(ApiEndpoints.forgotPassword)
  Future<ApiEnvelope<dynamic>> forgotPassword(@Body() EmailRequest request);

  /// Bumps `tokenVersion`, so every existing session dies — including this
  /// one. The caller must send the user back to login afterwards.
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
