// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String? ?? '',
  role: json['role'] as String? ?? 'customer',
  avatar: json['avatar'] == null
      ? null
      : AvatarModel.fromJson(json['avatar'] as Map<String, dynamic>),
  addresses:
      (json['addresses'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  lastLoginAt: json['lastLoginAt'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'role': instance.role,
  'avatar': instance.avatar,
  'addresses': instance.addresses,
  'isEmailVerified': instance.isEmailVerified,
  'isActive': instance.isActive,
  'lastLoginAt': instance.lastLoginAt,
  'createdAt': instance.createdAt,
};

AvatarModel _$AvatarModelFromJson(Map<String, dynamic> json) => AvatarModel(
  url: json['url'] as String? ?? '',
  publicId: json['publicId'] as String? ?? '',
);

Map<String, dynamic> _$AvatarModelToJson(AvatarModel instance) =>
    <String, dynamic>{'url': instance.url, 'publicId': instance.publicId};

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: json['_id'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  street: json['street'] as String,
  city: json['city'] as String,
  label: json['label'] as String? ?? 'Home',
  type: json['type'] as String? ?? 'home',
  state: json['state'] as String? ?? '',
  postalCode: json['postalCode'] as String? ?? '',
  country: json['country'] as String? ?? 'Nepal',
  landmark: json['landmark'] as String? ?? '',
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'label': instance.label,
      'type': instance.type,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'landmark': instance.landmark,
      'isDefault': instance.isDefault,
    };
