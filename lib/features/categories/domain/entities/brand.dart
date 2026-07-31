import 'package:equatable/equatable.dart';

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

  final String? logoUrl;

  final String? website;

  final String country;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasLogo => logoUrl != null;

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
