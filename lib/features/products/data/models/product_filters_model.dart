import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_filters.dart';

part 'product_filters_model.g.dart';

/// Wire format for `GET /products/filters`.
///
/// All six keys are always present in the response — the backend builds the
/// object unconditionally — so the defaults here are belt-and-braces for a
/// cached payload written by an older build rather than for the live API.
@JsonSerializable(createToJson: true)
class ProductFiltersModel {
  const ProductFiltersModel({
    this.colors = const [],
    this.sizes = const [],
    this.brands = const [],
    this.categories = const [],
    this.tags = const [],
    this.priceRange = const PriceRangeModel(),
  });

  factory ProductFiltersModel.fromJson(Map<String, dynamic> json) =>
      _$ProductFiltersModelFromJson(json);

  final List<ColorFacetModel> colors;
  final List<FacetValueModel> sizes;
  final List<ReferenceFacetModel> brands;
  final List<ReferenceFacetModel> categories;
  final List<FacetValueModel> tags;
  final PriceRangeModel priceRange;

  Map<String, dynamic> toJson() => _$ProductFiltersModelToJson(this);

  ProductFilters toEntity() => ProductFilters(
        colors: colors.map((facet) => facet.toEntity()).toList(growable: false),
        sizes: sizes.map((facet) => facet.toEntity()).toList(growable: false),
        brands: brands.map((facet) => facet.toEntity()).toList(growable: false),
        categories:
            categories.map((facet) => facet.toEntity()).toList(growable: false),
        tags: tags.map((facet) => facet.toEntity()).toList(growable: false),
        priceRange: priceRange.toEntity(),
      );
}

@JsonSerializable()
class FacetValueModel {
  const FacetValueModel({required this.name, this.count = 0});

  factory FacetValueModel.fromJson(Map<String, dynamic> json) =>
      _$FacetValueModelFromJson(json);

  final String name;
  final int count;

  Map<String, dynamic> toJson() => _$FacetValueModelToJson(this);

  FacetValue toEntity() => FacetValue(name: name, count: count);
}

@JsonSerializable()
class ColorFacetModel {
  const ColorFacetModel({
    required this.name,
    this.hex = '#000000',
    this.count = 0,
  });

  factory ColorFacetModel.fromJson(Map<String, dynamic> json) =>
      _$ColorFacetModelFromJson(json);

  final String name;
  final String hex;
  final int count;

  Map<String, dynamic> toJson() => _$ColorFacetModelToJson(this);

  ColorFacet toEntity() => ColorFacet(name: name, hex: hex, count: count);
}

@JsonSerializable()
class ReferenceFacetModel {
  const ReferenceFacetModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.count = 0,
  });

  factory ReferenceFacetModel.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFacetModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;
  final int count;

  Map<String, dynamic> toJson() => _$ReferenceFacetModelToJson(this);

  ReferenceFacet toEntity() =>
      ReferenceFacet(id: id, name: name, slug: slug, count: count);
}

@JsonSerializable()
class PriceRangeModel {
  const PriceRangeModel({this.min = 0, this.max = 0});

  factory PriceRangeModel.fromJson(Map<String, dynamic> json) =>
      _$PriceRangeModelFromJson(json);

  final double min;
  final double max;

  Map<String, dynamic> toJson() => _$PriceRangeModelToJson(this);

  PriceRange toEntity() => PriceRange(min: min, max: max);
}
