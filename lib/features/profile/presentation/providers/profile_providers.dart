import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/profile_local_datasource.dart';
import '../../data/datasource/profile_remote_datasource.dart';
import '../../data/datasource/review_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../domain/usecases/review_usecases.dart';

part 'profile_providers.g.dart';

/// Wiring for the profile feature, kept apart from the notifiers so the whole
/// object graph reads in one place and a test can override a single edge.

@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) =>
    ProfileRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ProfileLocalDataSource profileLocalDataSource(Ref ref) =>
    ProfileLocalDataSource(ref.watch(accountCacheProvider));

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
      remote: ref.watch(profileRemoteDataSourceProvider),
      local: ref.watch(profileLocalDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
      preferences: ref.watch(preferencesServiceProvider),
    );

@Riverpod(keepAlive: true)
ReviewRemoteDataSource reviewRemoteDataSource(Ref ref) =>
    ReviewRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ReviewRepository reviewRepository(Ref ref) =>
    ReviewRepositoryImpl(ref.watch(reviewRemoteDataSourceProvider));

// ── Profile use cases ──────────────────────────────────────────────────────

@riverpod
GetProfileUseCase getProfileUseCase(Ref ref) =>
    GetProfileUseCase(ref.watch(profileRepositoryProvider));

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) =>
    UpdateProfileUseCase(ref.watch(profileRepositoryProvider));

@riverpod
UploadAvatarUseCase uploadAvatarUseCase(Ref ref) =>
    UploadAvatarUseCase(ref.watch(profileRepositoryProvider));

@riverpod
RemoveAvatarUseCase removeAvatarUseCase(Ref ref) =>
    RemoveAvatarUseCase(ref.watch(profileRepositoryProvider));

@riverpod
GetRecentlyViewedUseCase getRecentlyViewedUseCase(Ref ref) =>
    GetRecentlyViewedUseCase(ref.watch(profileRepositoryProvider));

@riverpod
ClearRecentlyViewedUseCase clearRecentlyViewedUseCase(Ref ref) =>
    ClearRecentlyViewedUseCase(ref.watch(profileRepositoryProvider));

// ── Review use cases ───────────────────────────────────────────────────────

@riverpod
GetMyReviewsUseCase getMyReviewsUseCase(Ref ref) =>
    GetMyReviewsUseCase(ref.watch(reviewRepositoryProvider));

@riverpod
GetReviewableProductsUseCase getReviewableProductsUseCase(Ref ref) =>
    GetReviewableProductsUseCase(ref.watch(reviewRepositoryProvider));

@riverpod
CreateReviewUseCase createReviewUseCase(Ref ref) =>
    CreateReviewUseCase(ref.watch(reviewRepositoryProvider));

@riverpod
UpdateReviewUseCase updateReviewUseCase(Ref ref) =>
    UpdateReviewUseCase(ref.watch(reviewRepositoryProvider));

@riverpod
DeleteReviewUseCase deleteReviewUseCase(Ref ref) =>
    DeleteReviewUseCase(ref.watch(reviewRepositoryProvider));
