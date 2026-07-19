import 'package:equatable/equatable.dart';

/// A facet value with the number of products that carry it.
///
/// `/products/filters` returns counts for every facet so the sheet can grey
/// out or hide values that would produce an empty result set.
class FacetValue extends Equatable {
  const FacetValue({required this.name, required this.count});

  final String name;
  final int count;

  @override
  List<Object?> get props => [name, count];
}

/// A colour facet — like [FacetValue] but carrying the swatch.
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

/// A brand or category facet. Filtering is by [slug]; [id] is kept because
/// the `category` query parameter accepts either.
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

/// The catalogue-wide price bounds, used to seed the range slider.
class PriceRange extends Equatable {
  const PriceRange({required this.min, required this.max});

  final double min;
  final double max;

  /// A degenerate range (everything costs the same, or the catalogue is
  /// empty) would give the slider a zero-width track. Callers check this and
  /// hide the control rather than dividing by zero.
  bool get isCollapsed => max <= min;

  @override
  List<Object?> get props => [min, max];
}

/// The facets `/products/filters` offers, driving [ProductFilterSheet].
///
/// All six keys are always present in the response, so no field is nullable —
/// an empty list means "no values", not "not returned".
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
