import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';

/// What the categories screen renders.
///
/// The tree and the brand list carry their own failures rather than sharing
/// one screen-level error, because they come from independent endpoints: a
/// dead `/brands` must not take the taxonomy down with it, and vice versa.
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

  /// The state to start from when the cache already holds something: paint it
  /// straight away and mark a refresh as in flight.
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

  /// A first load with nothing cached to show underneath it.
  final bool isLoading;

  /// A refresh happening behind content that is already on screen.
  final bool isRefreshing;

  /// True while what is displayed came off disk rather than the network.
  final bool isFromCache;

  bool get hasTree => tree.isNotEmpty;

  bool get hasBrands => brands.isNotEmpty;

  bool get hasAnyContent => hasTree || hasBrands;

  /// The failure worth putting on an otherwise empty screen.
  ///
  /// Null whenever *anything* is renderable — a partial screen with one quiet
  /// gap beats replacing a working taxonomy with an error page because the
  /// brand strip happened to 500.
  Failure? get blockingFailure =>
      hasAnyContent ? null : (treeFailure ?? brandsFailure);

  /// Every category in the tree, depth-first. Cheap enough to recompute and
  /// used for the flat search over an otherwise hierarchical screen.
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
