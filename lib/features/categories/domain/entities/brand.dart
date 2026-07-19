import 'package:equatable/equatable.dart';

/// A catalogue brand.
///
/// Structurally a near-twin of `Category`, with one trap: the image object is
/// keyed `logo` here and `image` there. Same `{url, publicId}` shape, different
/// name — modelling them separately is cheaper than a shared type that has to
/// be told which key to read.
class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.logoUrl,
    this.website,
    this.country = '',
    this.isActive = true,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String description;

  /// Null when `logo.url` was the API's empty-string "no image" sentinel.
  final String? logoUrl;

  /// Null when unset — again normalised from `""` in the model.
  final String? website;

  final String country;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasLogo => logoUrl != null;

  /// Up to two letters, for the tile shown when a brand has no logo.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        logoUrl,
        website,
        country,
        isActive,
        isFeatured,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
