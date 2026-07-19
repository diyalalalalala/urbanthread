import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../cart/data/datasource/outbox_queue.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../data/datasource/wishlist_local_datasource.dart';
import '../../data/datasource/wishlist_remote_datasource.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/check_wishlist_usecase.dart';
import '../../domain/usecases/clear_wishlist_usecase.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/move_wishlist_item_to_cart_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';
import '../../domain/usecases/sync_wishlist_usecase.dart';

part 'wishlist_providers.g.dart';

/// Wiring for the wishlist feature.
///
/// The one edge that points at another feature is [cartLocalDataSourceProvider]:
/// move-to-cart answers with both halves, and the cart half is written to the
/// cart's own cache so the two never disagree on disk. The dependency runs
/// wishlist → cart only.

@Riverpod(keepAlive: true)
WishlistRemoteDataSource wishlistRemoteDataSource(Ref ref) =>
    WishlistRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
WishlistLocalDataSource wishlistLocalDataSource(Ref ref) =>
    WishlistLocalDataSource(ref.watch(accountCacheProvider));

/// The wishlist's slice of the shared `outbox` box.
@Riverpod(keepAlive: true)
OutboxQueue wishlistOutbox(Ref ref) => OutboxQueue(
      store: ref.watch(outboxCacheProvider),
      namespace: WishlistOutboxKinds.namespace,
    );

@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(Ref ref) => WishlistRepositoryImpl(
      remote: ref.watch(wishlistRemoteDataSourceProvider),
      local: ref.watch(wishlistLocalDataSourceProvider),
      cartLocal: ref.watch(cartLocalDataSourceProvider),
      outbox: ref.watch(wishlistOutboxProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
GetWishlistUseCase getWishlistUseCase(Ref ref) =>
    GetWishlistUseCase(ref.watch(wishlistRepositoryProvider));

@riverpod
AddToWishlistUseCase addToWishlistUseCase(Ref ref) =>
    AddToWishlistUseCase(ref.watch(wishlistRepositoryProvider));

@riverpod
RemoveFromWishlistUseCase removeFromWishlistUseCase(Ref ref) =>
    RemoveFromWishlistUseCase(ref.watch(wishlistRepositoryProvider));

@riverpod
ClearWishlistUseCase clearWishlistUseCase(Ref ref) =>
    ClearWishlistUseCase(ref.watch(wishlistRepositoryProvider));

@riverpod
MoveWishlistItemToCartUseCase moveWishlistItemToCartUseCase(Ref ref) =>
    MoveWishlistItemToCartUseCase(ref.watch(wishlistRepositoryProvider));

@riverpod
CheckWishlistUseCase checkWishlistUseCase(Ref ref) =>
    CheckWishlistUseCase(ref.watch(wishlistRepositoryProvider));

@riverpod
SyncWishlistUseCase syncWishlistUseCase(Ref ref) =>
    SyncWishlistUseCase(ref.watch(wishlistRepositoryProvider));
