import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import 'product_providers.dart';

part 'product_detail_notifier.g.dart';

/// The product page: the product itself plus the shopper's variant choice.
///
/// Selection lives here rather than in the widget because it is what the cart
/// needs — adding to the basket posts a `variantId`, and that decision is
/// made on this screen. Keeping it in provider state means the add-to-cart
/// action can be wired up from anywhere on the page without threading
/// callbacks through the gallery and the selector.
class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.product,
    this.isLoading = true,
    this.failure,
    this.selectedColor,
    this.selectedSize,
    this.quantity = 1,
  });

  final Product? product;
  final bool isLoading;
  final Failure? failure;

  /// Colour is identified by name — the same identity the backend's variant
  /// filter uses. Hex is presentation only.
  final String? selectedColor;
  final String? selectedSize;

  final int quantity;

  /// The variant both selections point at, or null while the choice is
  /// incomplete or the combination does not exist.
  ProductVariant? get selectedVariant {
    if (product == null || selectedColor == null || selectedSize == null) {
      return null;
    }
    return product!.variantFor(color: selectedColor, size: selectedSize);
  }

  /// Price for the current choice, falling back to the product price before
  /// a variant is picked so the page never shows a blank price.
  double get displayPrice =>
      product == null ? 0 : product!.priceForVariant(selectedVariant);

  /// True when the shopper has picked a real, purchasable combination.
  bool get canAddToCart {
    final variant = selectedVariant;
    return variant != null && variant.isSelectable && quantity <= variant.stock;
  }

  /// How many units may still be added. Zero when nothing is selected, so a
  /// quantity stepper cannot run ahead of the choice.
  int get maxQuantity => selectedVariant?.stock ?? 0;

  ProductDetailState copyWith({
    Product? product,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
    String? selectedColor,
    String? selectedSize,
    int? quantity,
  }) =>
      ProductDetailState(
        product: product ?? this.product,
        isLoading: isLoading ?? this.isLoading,
        failure: clearFailure ? null : (failure ?? this.failure),
        selectedColor: selectedColor ?? this.selectedColor,
        selectedSize: selectedSize ?? this.selectedSize,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [
        product,
        isLoading,
        failure,
        selectedColor,
        selectedSize,
        quantity,
      ];
}

/// Loads a product page by slug and tracks the variant selection on it.
@riverpod
class ProductDetailNotifier extends _$ProductDetailNotifier {
  @override
  ProductDetailState build(String slug) {
    unawaited(_load(slug));
    return const ProductDetailState();
  }

  Future<void> _load(String slug) async {
    final result = await ref.read(getProductDetailUseCaseProvider)(slug);

    switch (result) {
      case Success(:final value):
        final color = _defaultColor(value);
        state = ProductDetailState(
          product: value,
          isLoading: false,
          selectedColor: color,
          selectedSize: color == null ? null : _defaultSize(value, color),
        );
      case FailureResult(:final failure):
        state = ProductDetailState(isLoading: false, failure: failure);
    }
  }

  /// Preselect the first colour that actually has stock, so the page opens on
  /// a buyable combination rather than on a sold-out one the shopper then has
  /// to click away from. Falls back to the first colour when everything is
  /// out of stock — the selector still has to show something.
  String? _defaultColor(Product product) {
    for (final variant in product.variants) {
      if (variant.isSelectable) return variant.color.name;
    }
    final colors = product.availableColors;
    return colors.isEmpty ? null : colors.first.name;
  }

  String? _defaultSize(Product product, String color) {
    for (final variant in product.variants) {
      if (variant.isSelectable && variant.color.name == color) {
        return variant.size;
      }
    }
    final sizes = product.sizesForColor(color);
    return sizes.isEmpty ? null : sizes.first;
  }

  /// Picks a colour, and moves the size along with it if the current size is
  /// not offered in that colour — leaving an impossible pair selected would
  /// silently disable the buy button with no explanation.
  void selectColor(String color) {
    final product = state.product;
    if (product == null) return;

    final sizes = product.sizesForColor(color);
    final size = sizes.contains(state.selectedSize)
        ? state.selectedSize
        : _defaultSize(product, color);

    state = ProductDetailState(
      product: product,
      isLoading: false,
      selectedColor: color,
      selectedSize: size,
      quantity: 1,
    );
  }

  void selectSize(String size) {
    if (state.product == null) return;
    state = state.copyWith(selectedSize: size, quantity: 1);
  }

  /// Clamped to the selected variant's stock: the backend re-checks it at
  /// checkout and a 422 there is a far worse place to learn about it.
  void setQuantity(int quantity) {
    final max = state.maxQuantity;
    if (max == 0) return;
    state = state.copyWith(quantity: quantity.clamp(1, max));
  }

  void incrementQuantity() => setQuantity(state.quantity + 1);

  void decrementQuantity() => setQuantity(state.quantity - 1);

  Future<void> retry() async {
    state = const ProductDetailState();
    await _load(slug);
  }
}
