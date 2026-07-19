import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/cart_local_datasource.dart';
import '../../data/datasource/cart_remote_datasource.dart';
import '../../data/datasource/outbox_queue.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_summary_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/move_to_cart_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/remove_coupon_usecase.dart';
import '../../domain/usecases/save_for_later_usecase.dart';
import '../../domain/usecases/sync_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import '../../domain/usecases/validate_cart_usecase.dart';

part 'cart_providers.g.dart';

/// Wiring for the cart feature.
///
/// The repository is kept alive: it owns the offline write queue, and a
/// disposed instance would mean a queued mutation losing the object that knows
/// how to replay it.

@Riverpod(keepAlive: true)
CartRemoteDataSource cartRemoteDataSource(Ref ref) =>
    CartRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
CartLocalDataSource cartLocalDataSource(Ref ref) =>
    CartLocalDataSource(ref.watch(accountCacheProvider));

/// The cart's slice of the shared `outbox` box.
@Riverpod(keepAlive: true)
OutboxQueue cartOutbox(Ref ref) => OutboxQueue(
      store: ref.watch(outboxCacheProvider),
      namespace: CartOutboxKinds.namespace,
    );

@Riverpod(keepAlive: true)
CartRepository cartRepository(Ref ref) => CartRepositoryImpl(
      remote: ref.watch(cartRemoteDataSourceProvider),
      local: ref.watch(cartLocalDataSourceProvider),
      outbox: ref.watch(cartOutboxProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
GetCartUseCase getCartUseCase(Ref ref) =>
    GetCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
GetCartSummaryUseCase getCartSummaryUseCase(Ref ref) =>
    GetCartSummaryUseCase(ref.watch(cartRepositoryProvider));

@riverpod
ValidateCartUseCase validateCartUseCase(Ref ref) =>
    ValidateCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
AddToCartUseCase addToCartUseCase(Ref ref) =>
    AddToCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase(Ref ref) =>
    UpdateCartItemQuantityUseCase(ref.watch(cartRepositoryProvider));

@riverpod
RemoveCartItemUseCase removeCartItemUseCase(Ref ref) =>
    RemoveCartItemUseCase(ref.watch(cartRepositoryProvider));

@riverpod
SaveForLaterUseCase saveForLaterUseCase(Ref ref) =>
    SaveForLaterUseCase(ref.watch(cartRepositoryProvider));

@riverpod
MoveToCartUseCase moveToCartUseCase(Ref ref) =>
    MoveToCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
ApplyCouponUseCase applyCouponUseCase(Ref ref) =>
    ApplyCouponUseCase(ref.watch(cartRepositoryProvider));

@riverpod
RemoveCouponUseCase removeCouponUseCase(Ref ref) =>
    RemoveCouponUseCase(ref.watch(cartRepositoryProvider));

@riverpod
ClearCartUseCase clearCartUseCase(Ref ref) =>
    ClearCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
SyncCartUseCase syncCartUseCase(Ref ref) =>
    SyncCartUseCase(ref.watch(cartRepositoryProvider));
