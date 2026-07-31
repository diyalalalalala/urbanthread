import 'package:json_annotation/json_annotation.dart';

part 'api_envelope.g.dart';

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

  final int? nextPage;
  final int? prevPage;

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);

  static PaginationMeta single(int count) => PaginationMeta(
        page: 1,
        limit: count,
        total: count,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
}
