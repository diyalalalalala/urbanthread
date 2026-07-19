import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Wire format for a user.
///
/// Two API quirks are absorbed here so the domain never sees them:
///
/// 1. **`_id` vs `id`.** The backend has no `toJSON` transform, so hydrated
///    documents carry both while `.lean()` reads carry only `_id`. Since
///    `lean` is the repository default, `_id` is the only field present on
///    every path — it is the one we read.
/// 2. **Empty strings as null.** `phone` and `avatar.url` default to `""`,
///    not null. They are normalised on the way into the entity.
@JsonSerializable(createToJson: true)
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'customer',
    this.avatar,
    this.addresses = const [],
    this.isEmailVerified = false,
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final AvatarModel? avatar;
  final List<AddressModel> addresses;
  final bool isEmailVerified;
  final bool isActive;

  /// Absent entirely — not null — for a user who has never logged in.
  final String? lastLoginAt;
  final String? createdAt;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: UserRole.parse(role),
        avatarUrl: MediaUrl.resolve(avatar?.url),
        addresses: addresses
            .map((address) => address.toEntity())
            .toList(growable: false),
        isEmailVerified: isEmailVerified,
        isActive: isActive,
        lastLoginAt: _parseDate(lastLoginAt),
        createdAt: _parseDate(createdAt),
      );
}

@JsonSerializable()
class AvatarModel {
  const AvatarModel({this.url = '', this.publicId = ''});

  factory AvatarModel.fromJson(Map<String, dynamic> json) =>
      _$AvatarModelFromJson(json);

  final String url;
  final String publicId;

  Map<String, dynamic> toJson() => _$AvatarModelToJson(this);
}

@JsonSerializable()
class AddressModel {
  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.label = 'Home',
    this.type = 'home',
    this.state = '',
    this.postalCode = '',
    this.country = 'Nepal',
    this.landmark = '',
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String label;
  final String type;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String landmark;
  final bool isDefault;

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  Address toEntity() => Address(
        id: id,
        label: label,
        type: AddressType.parse(type),
        fullName: fullName,
        phone: phone,
        street: street,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        landmark: landmark,
        isDefault: isDefault,
      );
}

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
