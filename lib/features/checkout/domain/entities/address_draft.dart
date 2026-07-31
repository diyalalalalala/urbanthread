import 'package:equatable/equatable.dart';

import '../../../authentication/domain/entities/user.dart';

class AddressDraft extends Equatable {
  const AddressDraft({
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

  AddressDraft.from(Address address)
      : fullName = address.fullName,
        phone = address.phone,
        street = address.street,
        city = address.city,
        label = address.label,
        type = address.type,
        state = address.state,
        postalCode = address.postalCode,
        country = address.country,
        landmark = address.landmark,
        isDefault = address.isDefault;

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

  AddressDraft copyWith({
    String? label,
    AddressType? type,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? landmark,
    bool? isDefault,
  }) =>
      AddressDraft(
        label: label ?? this.label,
        type: type ?? this.type,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        postalCode: postalCode ?? this.postalCode,
        country: country ?? this.country,
        landmark: landmark ?? this.landmark,
        isDefault: isDefault ?? this.isDefault,
      );

  bool get isComplete =>
      fullName.trim().length >= 2 &&
      phone.trim().isNotEmpty &&
      street.trim().isNotEmpty &&
      city.trim().isNotEmpty;

  @override
  List<Object?> get props => [
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
