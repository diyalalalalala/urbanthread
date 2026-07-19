import 'package:equatable/equatable.dart';

/// A page of results plus the cursor needed to ask for the next one.
///
/// Domain-side mirror of the API's `meta` block, deliberately narrower: the
/// UI only ever needs "what did I get" and "is there more", so `prevPage` and
/// `limit` are dropped rather than carried around unused.
class Paginated<T> extends Equatable {
  const Paginated({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hasNextPage,
  });

  /// A complete, single-page result — what the non-paginated list endpoints
  /// (`/products/featured`, `/categories/tree`) effectively return.
  const Paginated.single(this.items)
      : page = 1,
        totalPages = 1,
        total = items.length,
        hasNextPage = false;

  const Paginated.empty()
      : items = const [],
        page = 1,
        totalPages = 0,
        total = 0,
        hasNextPage = false;

  final List<T> items;
  final int page;
  final int totalPages;
  final int total;
  final bool hasNextPage;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// The page to request next, or null at the end of the list.
  int? get nextPage => hasNextPage ? page + 1 : null;

  /// Appends [next] onto this page, as an infinite scroll does.
  ///
  /// Paging metadata is taken from [next] because it is the more recent
  /// truth — the total can shift between requests as stock changes.
  Paginated<T> append(Paginated<T> next) => Paginated<T>(
        items: [...items, ...next.items],
        page: next.page,
        totalPages: next.totalPages,
        total: next.total,
        hasNextPage: next.hasNextPage,
      );

  Paginated<R> map<R>(R Function(T item) transform) => Paginated<R>(
        items: items.map(transform).toList(growable: false),
        page: page,
        totalPages: totalPages,
        total: total,
        hasNextPage: hasNextPage,
      );

  @override
  List<Object?> get props => [items, page, totalPages, total, hasNextPage];
}
