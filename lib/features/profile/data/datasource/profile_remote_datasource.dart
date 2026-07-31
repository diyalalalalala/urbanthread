import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/recently_viewed_model.dart';
import '../models/update_profile_request.dart';

part 'profile_remote_datasource.g.dart';

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

  @POST(ApiEndpoints.avatar)
  Future<ApiEnvelope<UserModel>> uploadAvatar(@Body() FormData form);

  @DELETE(ApiEndpoints.avatar)
  Future<ApiEnvelope<UserModel>> removeAvatar();

  @GET(ApiEndpoints.recentlyViewed)
  Future<ApiEnvelope<List<RecentlyViewedModel>>> getRecentlyViewed();

  @DELETE(ApiEndpoints.recentlyViewed)
  Future<void> clearRecentlyViewed();
}
