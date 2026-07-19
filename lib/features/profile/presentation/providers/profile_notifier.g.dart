// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The profile screen's copy of `/users/me`.
///
/// Distinct from `authProvider`, which owns the *session*. This one owns the
/// screen: it can be refreshed, it can be in a failed state, and it can be
/// mutated — none of which should be able to sign anyone out. After a
/// successful mutation the session is told to re-read itself, so the app
/// shell (avatar in the app bar, name in the drawer) follows along.

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierProvider._();

/// The profile screen's copy of `/users/me`.
///
/// Distinct from `authProvider`, which owns the *session*. This one owns the
/// screen: it can be refreshed, it can be in a failed state, and it can be
/// mutated — none of which should be able to sign anyone out. After a
/// successful mutation the session is told to re-read itself, so the app
/// shell (avatar in the app bar, name in the drawer) follows along.
final class ProfileNotifierProvider
    extends $AsyncNotifierProvider<ProfileNotifier, User> {
  /// The profile screen's copy of `/users/me`.
  ///
  /// Distinct from `authProvider`, which owns the *session*. This one owns the
  /// screen: it can be refreshed, it can be in a failed state, and it can be
  /// mutated — none of which should be able to sign anyone out. After a
  /// successful mutation the session is told to re-read itself, so the app
  /// shell (avatar in the app bar, name in the drawer) follows along.
  ProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();
}

String _$profileNotifierHash() => r'26fe8c213f95088aab8eab1f6c2b1123939cf3b8';

/// The profile screen's copy of `/users/me`.
///
/// Distinct from `authProvider`, which owns the *session*. This one owns the
/// screen: it can be refreshed, it can be in a failed state, and it can be
/// mutated — none of which should be able to sign anyone out. After a
/// successful mutation the session is told to re-read itself, so the app
/// shell (avatar in the app bar, name in the drawer) follows along.

abstract class _$ProfileNotifier extends $AsyncNotifier<User> {
  FutureOr<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<User>, User>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User>, User>,
              AsyncValue<User>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
