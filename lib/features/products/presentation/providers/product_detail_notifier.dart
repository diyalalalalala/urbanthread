import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import 'product_providers.dart';

part 'product_detail_notifier.g.dart';

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

  final String? selectedColor;
  final String? selectedSize;

  final int quantity;

  ProductVariant? get selectedVariant {
    if (product == null || selectedColor == null || selectedSize == null) {
      return null;
    }
    return product!.variantFor(color: selectedColor, size: selectedSize);
  }

  double get displayPrice =>
      product == null ? 0 : product!.priceForVariant(selectedVariant);

  bool get canAddToCart {
    final variant = selectedVariant;
    return variant != null && variant.isSelectable && quantity <= variant.stock;
  }

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
