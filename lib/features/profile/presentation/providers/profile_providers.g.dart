// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the profile feature, kept apart from the notifiers so the whole
/// object graph reads in one place and a test can override a single edge.

@ProviderFor(profileRemoteDataSource)
final profileRemoteDataSourceProvider = ProfileRemoteDataSourceProvider._();

/// Wiring for the profile feature, kept apart from the notifiers so the whole
/// object graph reads in one place and a test can override a single edge.

final class ProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProfileRemoteDataSource,
          ProfileRemoteDataSource,
          ProfileRemoteDataSource
        >
    with $Provider<ProfileRemoteDataSource> {
  /// Wiring for the profile feature, kept apart from the notifiers so the whole
  /// object graph reads in one place and a test can override a single edge.
  ProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRemoteDataSource create(Ref ref) {
    return profileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRemoteDataSource>(value),
    );
  }
}

String _$profileRemoteDataSourceHash() =>
    r'59ac73fa3cb5e8343f67cc0117538edcba590cb7';

@ProviderFor(profileLocalDataSource)
final profileLocalDataSourceProvider = ProfileLocalDataSourceProvider._();

final class ProfileLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ProfileLocalDataSource,
          ProfileLocalDataSource,
          ProfileLocalDataSource
        >
    with $Provider<ProfileLocalDataSource> {
  ProfileLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProfileLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileLocalDataSource create(Ref ref) {
    return profileLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileLocalDataSource>(value),
    );
  }
}

String _$profileLocalDataSourceHash() =>
    r'bedc8ad2dee2f0d0f29f76f6042857cbbdf3350e';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'b63f84345fbe9f679e84f32570de5bbbc84e7ffb';

@ProviderFor(reviewRemoteDataSource)
final reviewRemoteDataSourceProvider = ReviewRemoteDataSourceProvider._();

final class ReviewRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ReviewRemoteDataSource,
          ReviewRemoteDataSource,
          ReviewRemoteDataSource
        >
    with $Provider<ReviewRemoteDataSource> {
  ReviewRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ReviewRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewRemoteDataSource create(Ref ref) {
    return reviewRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRemoteDataSource>(value),
    );
  }
}

String _$reviewRemoteDataSourceHash() =>
    r'6cc1e8134ceabde424c943f8348f9e67c21a1176';

@ProviderFor(reviewRepository)
final reviewRepositoryProvider = ReviewRepositoryProvider._();

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewRepository,
          ReviewRepository,
          ReviewRepository
        >
    with $Provider<ReviewRepository> {
  ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'21a19e5c6e530f59c329cc3ff124a84f7dce806b';

@ProviderFor(getProfileUseCase)
final getProfileUseCaseProvider = GetProfileUseCaseProvider._();

final class GetProfileUseCaseProvider
    extends
        $FunctionalProvider<
          GetProfileUseCase,
          GetProfileUseCase,
          GetProfileUseCase
        >
    with $Provider<GetProfileUseCase> {
  GetProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProfileUseCase create(Ref ref) {
    return getProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProfileUseCase>(value),
    );
  }
}

String _$getProfileUseCaseHash() => r'4ca5227c3643973b574558ffeeca3aa9c10c4dce';

@ProviderFor(updateProfileUseCase)
final updateProfileUseCaseProvider = UpdateProfileUseCaseProvider._();

final class UpdateProfileUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateProfileUseCase,
          UpdateProfileUseCase,
          UpdateProfileUseCase
        >
    with $Provider<UpdateProfileUseCase> {
  UpdateProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateProfileUseCase create(Ref ref) {
    return updateProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfileUseCase>(value),
    );
  }
}

String _$updateProfileUseCaseHash() =>
    r'1d9baca8efbdc0053489383ccfa1d0a2bc62a446';

@ProviderFor(uploadAvatarUseCase)
final uploadAvatarUseCaseProvider = UploadAvatarUseCaseProvider._();

final class UploadAvatarUseCaseProvider
    extends
        $FunctionalProvider<
          UploadAvatarUseCase,
          UploadAvatarUseCase,
          UploadAvatarUseCase
        >
    with $Provider<UploadAvatarUseCase> {
  UploadAvatarUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadAvatarUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadAvatarUseCaseHash();

  @$internal
  @override
  $ProviderElement<UploadAvatarUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UploadAvatarUseCase create(Ref ref) {
    return uploadAvatarUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UploadAvatarUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UploadAvatarUseCase>(value),
    );
  }
}

String _$uploadAvatarUseCaseHash() =>
    r'c01b47b68e0537385abbf69ef3e40499f5c36f1c';

@ProviderFor(removeAvatarUseCase)
final removeAvatarUseCaseProvider = RemoveAvatarUseCaseProvider._();

final class RemoveAvatarUseCaseProvider
    extends
        $FunctionalProvider<
          RemoveAvatarUseCase,
          RemoveAvatarUseCase,
          RemoveAvatarUseCase
        >
    with $Provider<RemoveAvatarUseCase> {
  RemoveAvatarUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeAvatarUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeAvatarUseCaseHash();

  @$internal
  @override
  $ProviderElement<RemoveAvatarUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveAvatarUseCase create(Ref ref) {
    return removeAvatarUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveAvatarUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveAvatarUseCase>(value),
    );
  }
}

String _$removeAvatarUseCaseHash() =>
    r'21a58e9dd4d71edd1d047d22e6ccad50a206864e';

@ProviderFor(getRecentlyViewedUseCase)
final getRecentlyViewedUseCaseProvider = GetRecentlyViewedUseCaseProvider._();

final class GetRecentlyViewedUseCaseProvider
    extends
        $FunctionalProvider<
          GetRecentlyViewedUseCase,
          GetRecentlyViewedUseCase,
          GetRecentlyViewedUseCase
        >
    with $Provider<GetRecentlyViewedUseCase> {
  GetRecentlyViewedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRecentlyViewedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRecentlyViewedUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRecentlyViewedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRecentlyViewedUseCase create(Ref ref) {
    return getRecentlyViewedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRecentlyViewedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRecentlyViewedUseCase>(value),
    );
  }
}

String _$getRecentlyViewedUseCaseHash() =>
    r'ecdee6f5116f2aeacc18c59c2d7bb0ac2d87f3f7';

@ProviderFor(clearRecentlyViewedUseCase)
final clearRecentlyViewedUseCaseProvider =
    ClearRecentlyViewedUseCaseProvider._();

final class ClearRecentlyViewedUseCaseProvider
    extends
        $FunctionalProvider<
          ClearRecentlyViewedUseCase,
          ClearRecentlyViewedUseCase,
          ClearRecentlyViewedUseCase
        >
    with $Provider<ClearRecentlyViewedUseCase> {
  ClearRecentlyViewedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearRecentlyViewedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearRecentlyViewedUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearRecentlyViewedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearRecentlyViewedUseCase create(Ref ref) {
    return clearRecentlyViewedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearRecentlyViewedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearRecentlyViewedUseCase>(value),
    );
  }
}

String _$clearRecentlyViewedUseCaseHash() =>
    r'a31d2d6fea8a18652d353f543d92034b0cf5834b';

@ProviderFor(getMyReviewsUseCase)
final getMyReviewsUseCaseProvider = GetMyReviewsUseCaseProvider._();

final class GetMyReviewsUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyReviewsUseCase,
          GetMyReviewsUseCase,
          GetMyReviewsUseCase
        >
    with $Provider<GetMyReviewsUseCase> {
  GetMyReviewsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyReviewsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyReviewsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyReviewsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyReviewsUseCase create(Ref ref) {
    return getMyReviewsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyReviewsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyReviewsUseCase>(value),
    );
  }
}

String _$getMyReviewsUseCaseHash() =>
    r'10b623db6e1ad18b202e64346f1bd4becbba4a92';

@ProviderFor(getReviewableProductsUseCase)
final getReviewableProductsUseCaseProvider =
    GetReviewableProductsUseCaseProvider._();

final class GetReviewableProductsUseCaseProvider
    extends
        $FunctionalProvider<
          GetReviewableProductsUseCase,
          GetReviewableProductsUseCase,
          GetReviewableProductsUseCase
        >
    with $Provider<GetReviewableProductsUseCase> {
  GetReviewableProductsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReviewableProductsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReviewableProductsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReviewableProductsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetReviewableProductsUseCase create(Ref ref) {
    return getReviewableProductsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReviewableProductsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReviewableProductsUseCase>(value),
    );
  }
}

String _$getReviewableProductsUseCaseHash() =>
    r'81ec31870992c7f6f562e98b0a2c99f2e9d3c6b7';

@ProviderFor(createReviewUseCase)
final createReviewUseCaseProvider = CreateReviewUseCaseProvider._();

final class CreateReviewUseCaseProvider
    extends
        $FunctionalProvider<
          CreateReviewUseCase,
          CreateReviewUseCase,
          CreateReviewUseCase
        >
    with $Provider<CreateReviewUseCase> {
  CreateReviewUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createReviewUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createReviewUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateReviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateReviewUseCase create(Ref ref) {
    return createReviewUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateReviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateReviewUseCase>(value),
    );
  }
}

String _$createReviewUseCaseHash() =>
    r'f9983c7a5f77324af02368578f9288e711942373';

@ProviderFor(updateReviewUseCase)
final updateReviewUseCaseProvider = UpdateReviewUseCaseProvider._();

final class UpdateReviewUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateReviewUseCase,
          UpdateReviewUseCase,
          UpdateReviewUseCase
        >
    with $Provider<UpdateReviewUseCase> {
  UpdateReviewUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateReviewUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateReviewUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateReviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateReviewUseCase create(Ref ref) {
    return updateReviewUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateReviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateReviewUseCase>(value),
    );
  }
}

String _$updateReviewUseCaseHash() =>
    r'f49abd510bec691631aa63875e28000eac2ca5fd';

@ProviderFor(deleteReviewUseCase)
final deleteReviewUseCaseProvider = DeleteReviewUseCaseProvider._();

final class DeleteReviewUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteReviewUseCase,
          DeleteReviewUseCase,
          DeleteReviewUseCase
        >
    with $Provider<DeleteReviewUseCase> {
  DeleteReviewUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteReviewUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteReviewUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteReviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteReviewUseCase create(Ref ref) {
    return deleteReviewUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteReviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteReviewUseCase>(value),
    );
  }
}

String _$deleteReviewUseCaseHash() =>
    r'a32334382858d88e543e3d12c016c901b9bcc4a9';
