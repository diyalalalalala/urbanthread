// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The paginated order history.
///
/// The generator strips the `Notifier` suffix, so this class is reached
/// through `ordersProvider`.

@ProviderFor(OrdersNotifier)
final ordersProvider = OrdersNotifierProvider._();

/// The paginated order history.
///
/// The generator strips the `Notifier` suffix, so this class is reached
/// through `ordersProvider`.
final class OrdersNotifierProvider
    extends $NotifierProvider<OrdersNotifier, OrdersState> {
  /// The paginated order history.
  ///
  /// The generator strips the `Notifier` suffix, so this class is reached
  /// through `ordersProvider`.
  OrdersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersNotifierHash();

  @$internal
  @override
  OrdersNotifier create() => OrdersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrdersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrdersState>(value),
    );
  }
}

String _$ordersNotifierHash() => r'ed146a2f16357252b1d598fff2862679bf296631';

/// The paginated order history.
///
/// The generator strips the `Notifier` suffix, so this class is reached
/// through `ordersProvider`.

abstract class _$OrdersNotifier extends $Notifier<OrdersState> {
  OrdersState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OrdersState, OrdersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrdersState, OrdersState>,
              OrdersState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// One order, by id.
///
/// A family, so navigating between two orders does not make them share a
/// slot — and so the detail screen for an order already visited rebuilds from
/// its own cache rather than the previous order's data.

@ProviderFor(OrderDetailNotifier)
final orderDetailProvider = OrderDetailNotifierFamily._();

/// One order, by id.
///
/// A family, so navigating between two orders does not make them share a
/// slot — and so the detail screen for an order already visited rebuilds from
/// its own cache rather than the previous order's data.
final class OrderDetailNotifierProvider
    extends $NotifierProvider<OrderDetailNotifier, OrderDetailState> {
  /// One order, by id.
  ///
  /// A family, so navigating between two orders does not make them share a
  /// slot — and so the detail screen for an order already visited rebuilds from
  /// its own cache rather than the previous order's data.
  OrderDetailNotifierProvider._({
    required OrderDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailNotifierHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrderDetailNotifier create() => OrderDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailNotifierHash() =>
    r'7d6c9d6f45134720b2202283b3b8f7e9b0f0d59e';

/// One order, by id.
///
/// A family, so navigating between two orders does not make them share a
/// slot — and so the detail screen for an order already visited rebuilds from
/// its own cache rather than the previous order's data.

final class OrderDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          OrderDetailNotifier,
          OrderDetailState,
          OrderDetailState,
          OrderDetailState,
          String
        > {
  OrderDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One order, by id.
  ///
  /// A family, so navigating between two orders does not make them share a
  /// slot — and so the detail screen for an order already visited rebuilds from
  /// its own cache rather than the previous order's data.

  OrderDetailNotifierProvider call(String orderId) =>
      OrderDetailNotifierProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderDetailProvider';
}

/// One order, by id.
///
/// A family, so navigating between two orders does not make them share a
/// slot — and so the detail screen for an order already visited rebuilds from
/// its own cache rather than the previous order's data.

abstract class _$OrderDetailNotifier extends $Notifier<OrderDetailState> {
  late final _$args = ref.$arg as String;
  String get orderId => _$args;

  OrderDetailState build(String orderId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OrderDetailState, OrderDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrderDetailState, OrderDetailState>,
              OrderDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// The tracking projection for one order.

@ProviderFor(OrderTrackingNotifier)
final orderTrackingProvider = OrderTrackingNotifierFamily._();

/// The tracking projection for one order.
final class OrderTrackingNotifierProvider
    extends $NotifierProvider<OrderTrackingNotifier, OrderTrackingState> {
  /// The tracking projection for one order.
  OrderTrackingNotifierProvider._({
    required OrderTrackingNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderTrackingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderTrackingNotifierHash();

  @override
  String toString() {
    return r'orderTrackingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrderTrackingNotifier create() => OrderTrackingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderTrackingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderTrackingState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackingNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderTrackingNotifierHash() =>
    r'49abe7aae0e00cdecbd15ffe0cf21a7960bc38ea';

/// The tracking projection for one order.

final class OrderTrackingNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          OrderTrackingNotifier,
          OrderTrackingState,
          OrderTrackingState,
          OrderTrackingState,
          String
        > {
  OrderTrackingNotifierFamily._()
    : super(
        retry: null,
        name: r'orderTrackingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tracking projection for one order.

  OrderTrackingNotifierProvider call(String orderId) =>
      OrderTrackingNotifierProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderTrackingProvider';
}

/// The tracking projection for one order.

abstract class _$OrderTrackingNotifier extends $Notifier<OrderTrackingState> {
  late final _$args = ref.$arg as String;
  String get orderId => _$args;

  OrderTrackingState build(String orderId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OrderTrackingState, OrderTrackingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrderTrackingState, OrderTrackingState>,
              OrderTrackingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
