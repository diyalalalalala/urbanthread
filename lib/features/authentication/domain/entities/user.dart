import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.label = 'Home',
    this.type = AddressType.home,
    this.state = '',
    this.postalCode = '',
    this.country = 'Nepal',
    this.landmark = '',
    this.isDefault = false,
  });

  final String id;
  final String label;
  final AddressType type;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String landmark;
  final bool isDefault;

  String get singleLine => [
        street,
        if (landmark.isNotEmpty) landmark,
        city,
        if (state.isNotEmpty) state,
        if (postalCode.isNotEmpty) postalCode,
        country,
      ].join(', ');

  @override
  List<Object?> get props => [
        id,
        label,
        type,
        fullName,
        phone,
        street,
        city,
        state,
        postalCode,
        country,
        landmark,
        isDefault,
      ];
}

enum AddressType {
  home,
  office,
  other;

  static AddressType parse(String? raw) => switch (raw?.toLowerCase()) {
        'office' => AddressType.office,
        'other' => AddressType.other,
        _ => AddressType.home,
      };

  String get wireValue => name;

  String get label => switch (this) {
        AddressType.home => 'Home',
        AddressType.office => 'Office',
        AddressType.other => 'Other',
      };
}

enum UserRole {
  customer,
  admin;

  static UserRole parse(String? raw) =>
      raw?.toLowerCase() == 'admin' ? UserRole.admin : UserRole.customer;
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = UserRole.customer,
    this.avatarUrl,
    this.addresses = const [],
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  final String? avatarUrl;

  final List<Address> addresses;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  Address? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  bool get hasAddresses => addresses.isNotEmpty;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  User copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    bool clearAvatar = false,
    List<Address>? addresses,
  }) =>
      User(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role,
        avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
        addresses: addresses ?? this.addresses,
        isActive: isActive,
        lastLoginAt: lastLoginAt,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        avatarUrl,
        addresses,
        isActive,
        lastLoginAt,
        createdAt,
      ];
}
