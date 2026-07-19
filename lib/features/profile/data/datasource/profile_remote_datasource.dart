import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/recently_viewed_model.dart';
import '../models/update_profile_request.dart';

part 'profile_remote_datasource.g.dart';

/// Typed HTTP surface for `/users/me`.
@RestApi()
abstract class ProfileRemoteDataSource {
  factory ProfileRemoteDataSource(Dio dio, {String baseUrl}) =
      _ProfileRemoteDataSource;

  @GET(ApiEndpoints.profile)
  Future<ApiEnvelope<UserModel>> getProfile();

  @PATCH(ApiEndpoints.profile)
  Future<ApiEnvelope<UserModel>> updateProfile(
    @Body() UpdateProfileRequest request,
  );

  /// `multipart/form-data` with a single file under the field name
  /// **`avatar`** — multer is configured with `.single('avatar')`, so any
  /// other field name is rejected as an unexpected file rather than ignored.
  ///
  /// The [FormData] is assembled by the repository so it can set an explicit
  /// `Content-Type` per file: the backend's `fileFilter` inspects the part's
  /// MIME type, and Dio's default of `application/octet-stream` would fail it.
  /// `AuthInterceptor` strips the request-level `Content-Type` for FormData
  /// so Dio can attach its own multipart boundary.
  @POST(ApiEndpoints.avatar)
  Future<ApiEnvelope<UserModel>> uploadAvatar(@Body() FormData form);

  @DELETE(ApiEndpoints.avatar)
  Future<ApiEnvelope<UserModel>> removeAvatar();

  /// Returns a bare array in `data`; there is no `meta` block to read.
  @GET(ApiEndpoints.recentlyViewed)
  Future<ApiEnvelope<List<RecentlyViewedModel>>> getRecentlyViewed();

  /// Answers **204 with no body**, so there is no envelope to decode — note
  /// the asymmetry with `DELETE /notifications/read`, which answers 200 and a
  /// count.
  @DELETE(ApiEndpoints.recentlyViewed)
  Future<void> clearRecentlyViewed();
}
