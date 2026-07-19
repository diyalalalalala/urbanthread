// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the orders feature.
///
/// Separated from the notifiers so the object graph reads in one place, and
/// so a test can override [orderRepositoryProvider] alone.

@ProviderFor(orderRemoteDataSource)
final orderRemoteDataSourceProvider = OrderRemoteDataSourceProvider._();

/// Wiring for the orders feature.
///
/// Separated from the notifiers so the object graph reads in one place, and
/// so a test can override [orderRepositoryProvider] alone.

final class OrderRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          OrderRemoteDataSource,
          OrderRemoteDataSource,
          OrderRemoteDataSource
        >
    with $Provider<OrderRemoteDataSource> {
  /// Wiring for the orders feature.
  ///
  /// Separated from the notifiers so the object graph reads in one place, and
  /// so a test can override [orderRepositoryProvider] alone.
  OrderRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<OrderRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrderRemoteDataSource create(Ref ref) {
    return orderRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRemoteDataSource>(value),
    );
  }
}

String _$orderRemoteDataSourceHash() =>
    r'95c4176735391414f06a2bf9830d66aaf416c4ce';

/// Orders cache into the `account` box — user data, cleared on sign-out,
/// spared when the catalogue cache is dropped to reclaim space.

@ProviderFor(orderLocalDataSource)
final orderLocalDataSourceProvider = OrderLocalDataSourceProvider._();

/// Orders cache into the `account` box — user data, cleared on sign-out,
/// spared when the catalogue cache is dropped to reclaim space.

final class OrderLocalDataSourceProvider
    extends
        $FunctionalProvider<
          OrderLocalDataSource,
          OrderLocalDataSource,
          OrderLocalDataSource
        >
    with $Provider<OrderLocalDataSource> {
  /// Orders cache into the `account` box — user data, cleared on sign-out,
  /// spared when the catalogue cache is dropped to reclaim space.
  OrderLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<OrderLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrderLocalDataSource create(Ref ref) {
    return orderLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderLocalDataSource>(value),
    );
  }
}

String _$orderLocalDataSourceHash() =>
    r'ff64bb5ea3b5f639c4a66e46cfcdf8a8c1220902';

@ProviderFor(orderRepository)
final orderRepositoryProvider = OrderRepositoryProvider._();

final class OrderRepositoryProvider
    extends
        $FunctionalProvider<OrderRepository, OrderRepository, OrderRepository>
    with $Provider<OrderRepository> {
  OrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderRepository create(Ref ref) {
    return orderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRepository>(value),
    );
  }
}

String _$orderRepositoryHash() => r'8e553ce5fb775ff1b14e71393da7bced23928931';

@ProviderFor(placeOrderUseCase)
final placeOrderUseCaseProvider = PlaceOrderUseCaseProvider._();

final class PlaceOrderUseCaseProvider
    extends
        $FunctionalProvider<
          PlaceOrderUseCase,
          PlaceOrderUseCase,
          PlaceOrderUseCase
        >
    with $Provider<PlaceOrderUseCase> {
  PlaceOrderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeOrderUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeOrderUseCaseHash();

  @$internal
  @override
  $ProviderElement<PlaceOrderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaceOrderUseCase create(Ref ref) {
    return placeOrderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceOrderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceOrderUseCase>(value),
    );
  }
}

String _$placeOrderUseCaseHash() => r'09ae8140cafed8afab0c8f768d585d8fcc80ab1a';

@ProviderFor(getMyOrdersUseCase)
final getMyOrdersUseCaseProvider = GetMyOrdersUseCaseProvider._();

final class GetMyOrdersUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyOrdersUseCase,
          GetMyOrdersUseCase,
          GetMyOrdersUseCase
        >
    with $Provider<GetMyOrdersUseCase> {
  GetMyOrdersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyOrdersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyOrdersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyOrdersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyOrdersUseCase create(Ref ref) {
    return getMyOrdersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyOrdersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyOrdersUseCase>(value),
    );
  }
}

String _$getMyOrdersUseCaseHash() =>
    r'55879001dd67f53e063d798655e298b196cbb29a';

@ProviderFor(getOrderByIdUseCase)
final getOrderByIdUseCaseProvider = GetOrderByIdUseCaseProvider._();

final class GetOrderByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetOrderByIdUseCase,
          GetOrderByIdUseCase,
          GetOrderByIdUseCase
        >
    with $Provider<GetOrderByIdUseCase> {
  GetOrderByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getOrderByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getOrderByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetOrderByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetOrderByIdUseCase create(Ref ref) {
    return getOrderByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetOrderByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetOrderByIdUseCase>(value),
    );
  }
}

String _$getOrderByIdUseCaseHash() =>
    r'7fc28cd2c359fc7b70f7301c58038265c3925d83';

@ProviderFor(getOrderByNumberUseCase)
final getOrderByNumberUseCaseProvider = GetOrderByNumberUseCaseProvider._();

final class GetOrderByNumberUseCaseProvider
    extends
        $FunctionalProvider<
          GetOrderByNumberUseCase,
          GetOrderByNumberUseCase,
          GetOrderByNumberUseCase
        >
    with $Provider<GetOrderByNumberUseCase> {
  GetOrderByNumberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getOrderByNumberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getOrderByNumberUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetOrderByNumberUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetOrderByNumberUseCase create(Ref ref) {
    return getOrderByNumberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetOrderByNumberUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetOrderByNumberUseCase>(value),
    );
  }
}

String _$getOrderByNumberUseCaseHash() =>
    r'75fe40431d515cd247c6278104ced5b1fb92d8de';

@ProviderFor(trackOrderUseCase)
final trackOrderUseCaseProvider = TrackOrderUseCaseProvider._();

final class TrackOrderUseCaseProvider
    extends
        $FunctionalProvider<
          TrackOrderUseCase,
          TrackOrderUseCase,
          TrackOrderUseCase
        >
    with $Provider<TrackOrderUseCase> {
  TrackOrderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackOrderUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackOrderUseCaseHash();

  @$internal
  @override
  $ProviderElement<TrackOrderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrackOrderUseCase create(Ref ref) {
    return trackOrderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackOrderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackOrderUseCase>(value),
    );
  }
}

String _$trackOrderUseCaseHash() => r'56eeb99813b7621e6da7236546db7f34f6f9e3e9';

@ProviderFor(cancelOrderUseCase)
final cancelOrderUseCaseProvider = CancelOrderUseCaseProvider._();

final class CancelOrderUseCaseProvider
    extends
        $FunctionalProvider<
          CancelOrderUseCase,
          CancelOrderUseCase,
          CancelOrderUseCase
        >
    with $Provider<CancelOrderUseCase> {
  CancelOrderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelOrderUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelOrderUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelOrderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelOrderUseCase create(Ref ref) {
    return cancelOrderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelOrderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelOrderUseCase>(value),
    );
  }
}

String _$cancelOrderUseCaseHash() =>
    r'486cbdfed72aa738132fd4ecbc493f841512f378';

@ProviderFor(requestReturnUseCase)
final requestReturnUseCaseProvider = RequestReturnUseCaseProvider._();

final class RequestReturnUseCaseProvider
    extends
        $FunctionalProvider<
          RequestReturnUseCase,
          RequestReturnUseCase,
          RequestReturnUseCase
        >
    with $Provider<RequestReturnUseCase> {
  RequestReturnUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestReturnUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestReturnUseCaseHash();

  @$internal
  @override
  $ProviderElement<RequestReturnUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestReturnUseCase create(Ref ref) {
    return requestReturnUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestReturnUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestReturnUseCase>(value),
    );
  }
}

String _$requestReturnUseCaseHash() =>
    r'b5d229ce7dbb7b37c35cf493256f48ecf9be8f16';
