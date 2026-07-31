import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';

class CategoriesState extends Equatable {
  const CategoriesState({
    this.tree = const [],
    this.brands = const [],
    this.treeFailure,
    this.brandsFailure,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  const CategoriesState.fromCache({
    required this.tree,
    required this.brands,
  })  : treeFailure = null,
        brandsFailure = null,
        isLoading = false,
        isRefreshing = true,
        isFromCache = true;

  const CategoriesState.loading()
      : tree = const [],
        brands = const [],
        treeFailure = null,
        brandsFailure = null,
        isLoading = true,
        isRefreshing = false,
        isFromCache = false;

  final List<CategoryNode> tree;
  final List<Brand> brands;
  final Failure? treeFailure;
  final Failure? brandsFailure;

  final bool isLoading;

  final bool isRefreshing;

  final bool isFromCache;

  bool get hasTree => tree.isNotEmpty;

  bool get hasBrands => brands.isNotEmpty;

  bool get hasAnyContent => hasTree || hasBrands;

  Failure? get blockingFailure =>
      hasAnyContent ? null : (treeFailure ?? brandsFailure);

  List<Category> get allCategories =>
      [for (final node in tree) ...node.flattened];

  CategoriesState copyWith({
    List<CategoryNode>? tree,
    List<Brand>? brands,
    Failure? treeFailure,
    Failure? brandsFailure,
    bool clearTreeFailure = false,
    bool clearBrandsFailure = false,
    bool? isLoading,
    bool? isRefreshing,
    bool? isFromCache,
  }) =>
      CategoriesState(
        tree: tree ?? this.tree,
        brands: brands ?? this.brands,
        treeFailure:
            clearTreeFailure ? null : (treeFailure ?? this.treeFailure),
        brandsFailure:
            clearBrandsFailure ? null : (brandsFailure ?? this.brandsFailure),
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isFromCache: isFromCache ?? this.isFromCache,
      );

  @override
  List<Object?> get props => [
        tree,
        brands,
        treeFailure,
        brandsFailure,
        isLoading,
        isRefreshing,
        isFromCache,
      ];
}
