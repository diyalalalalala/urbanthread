import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/checkout_remote_datasource.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../data/repositories/checkout_repository_impl.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/get_available_coupons_usecase.dart';
import '../../domain/usecases/get_cart_summary_usecase.dart';
import '../../domain/usecases/set_default_address_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import '../../domain/usecases/validate_cart_usecase.dart';
import '../../domain/usecases/validate_coupon_usecase.dart';

part 'checkout_providers.g.dart';

/// Wiring for the checkout feature.
///
/// One datasource serves three route families — cart reads, coupons and the
/// address book — because checkout is the only screen that needs all three at
/// once, and splitting them would mean three Dio-backed objects for six
/// endpoints.

@Riverpod(keepAlive: true)
CheckoutRemoteDataSource checkoutRemoteDataSource(Ref ref) =>
    CheckoutRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
CheckoutRepository checkoutRepository(Ref ref) => CheckoutRepositoryImpl(
      remote: ref.watch(checkoutRemoteDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@Riverpod(keepAlive: true)
AddressRepository addressRepository(Ref ref) => AddressRepositoryImpl(
      remote: ref.watch(checkoutRemoteDataSourceProvider),
      cache: ref.watch(accountCacheProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
ValidateCartUseCase validateCartUseCase(Ref ref) =>
    ValidateCartUseCase(ref.watch(checkoutRepositoryProvider));

@riverpod
GetCartSummaryUseCase getCartSummaryUseCase(Ref ref) =>
    GetCartSummaryUseCase(ref.watch(checkoutRepositoryProvider));

@riverpod
GetAvailableCouponsUseCase getAvailableCouponsUseCase(Ref ref) =>
    GetAvailableCouponsUseCase(ref.watch(checkoutRepositoryProvider));

@riverpod
ValidateCouponUseCase validateCouponUseCase(Ref ref) =>
    ValidateCouponUseCase(ref.watch(checkoutRepositoryProvider));

@riverpod
GetAddressesUseCase getAddressesUseCase(Ref ref) =>
    GetAddressesUseCase(ref.watch(addressRepositoryProvider));

@riverpod
AddAddressUseCase addAddressUseCase(Ref ref) =>
    AddAddressUseCase(ref.watch(addressRepositoryProvider));

@riverpod
UpdateAddressUseCase updateAddressUseCase(Ref ref) =>
    UpdateAddressUseCase(ref.watch(addressRepositoryProvider));

@riverpod
DeleteAddressUseCase deleteAddressUseCase(Ref ref) =>
    DeleteAddressUseCase(ref.watch(addressRepositoryProvider));

@riverpod
SetDefaultAddressUseCase setDefaultAddressUseCase(Ref ref) =>
    SetDefaultAddressUseCase(ref.watch(addressRepositoryProvider));
