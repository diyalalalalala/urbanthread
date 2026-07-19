import 'package:json_annotation/json_annotation.dart';

part 'api_envelope.g.dart';

/// The envelope every UrbanThread endpoint answers with:
/// `{ success, message, data, meta? }`.
///
/// Kept generic so Retrofit can decode `ApiEnvelope<ProductModel>` and
/// `ApiEnvelope<List<OrderModel>>` from the same class. `meta` is present only
/// on paginated routes, hence nullable.
@JsonSerializable(genericArgumentFactories: true)
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiEnvelopeFromJson(json, fromJsonT);

  final bool success;
  final String message;
  final T data;
  final PaginationMeta? meta;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiEnvelopeToJson(this, toJsonT);
}

/// Pagination block returned by `ApiResponse.paginated`.
///
/// The key names are the backend's own and differ from the usual Flutter
/// conventions — it is `hasNextPage`, not `hasNext`.
@JsonSerializable()
class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  /// Null on the last and first page respectively.
  final int? nextPage;
  final int? prevPage;

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);

  /// The meta a single-page, non-paginated response implies. Lets endpoints
  /// that return a bare array (`/products/featured`) flow through the same
  /// paged types as `/products` without a special case at every call site.
  static PaginationMeta single(int count) => PaginationMeta(
        page: 1,
        limit: count,
        total: count,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
}
