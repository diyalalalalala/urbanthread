// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiEnvelope<T> _$ApiEnvelopeFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiEnvelope<T>(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: fromJsonT(json['data']),
  meta: json['meta'] == null
      ? null
      : PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiEnvelopeToJson<T>(
  ApiEnvelope<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': toJsonT(instance.data),
  'meta': instance.meta,
};

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
      nextPage: (json['nextPage'] as num?)?.toInt(),
      prevPage: (json['prevPage'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
      'hasNextPage': instance.hasNextPage,
      'hasPrevPage': instance.hasPrevPage,
      'nextPage': instance.nextPage,
      'prevPage': instance.prevPage,
    };
