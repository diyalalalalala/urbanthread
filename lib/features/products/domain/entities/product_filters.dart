import 'package:equatable/equatable.dart';

class FacetValue extends Equatable {
  const FacetValue({required this.name, required this.count});

  final String name;
  final int count;

  @override
  List<Object?> get props => [name, count];
}

class ColorFacet extends Equatable {
  const ColorFacet({
    required this.name,
    required this.count,
    this.hex = '#000000',
  });

  final String name;
  final String hex;
  final int count;

  int? get argb {
    final cleaned = hex.replaceFirst('#', '').trim();
    final normalised = switch (cleaned.length) {
      6 => 'FF$cleaned',
      8 => cleaned,
      3 => 'FF${cleaned.split('').map((c) => '$c$c').join()}',
      _ => null,
    };
    if (normalised == null) return null;
    return int.tryParse(normalised, radix: 16);
  }

  @override
  List<Object?> get props => [name, hex, count];
}

class ReferenceFacet extends Equatable {
  const ReferenceFacet({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
  });

  final String id;
  final String name;
  final String slug;
  final int count;

  @override
  List<Object?> get props => [id, name, slug, count];
}

class PriceRange extends Equatable {
  const PriceRange({required this.min, required this.max});

  final double min;
  final double max;

  bool get isCollapsed => max <= min;

  @override
  List<Object?> get props => [min, max];
}

class ProductFilters extends Equatable {
  const ProductFilters({
    this.colors = const [],
    this.sizes = const [],
    this.brands = const [],
    this.categories = const [],
    this.tags = const [],
    this.priceRange = const PriceRange(min: 0, max: 0),
  });

  final List<ColorFacet> colors;
  final List<FacetValue> sizes;
  final List<ReferenceFacet> brands;
  final List<ReferenceFacet> categories;
  final List<FacetValue> tags;
  final PriceRange priceRange;

  bool get isEmpty =>
      colors.isEmpty &&
      sizes.isEmpty &&
      brands.isEmpty &&
      categories.isEmpty &&
      tags.isEmpty;

  @override
  List<Object?> get props => [
        colors,
        sizes,
        brands,
        categories,
        tags,
        priceRange,
      ];
}
