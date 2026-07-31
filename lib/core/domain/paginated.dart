import 'package:equatable/equatable.dart';

class Paginated<T> extends Equatable {
  const Paginated({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hasNextPage,
  });

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

  int? get nextPage => hasNextPage ? page + 1 : null;

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
