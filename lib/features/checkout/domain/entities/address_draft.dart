import 'package:equatable/equatable.dart';

import '../../../authentication/domain/entities/user.dart';

/// The editable fields of an address, for create and update.
///
/// The [Address] entity itself is reused from the authentication feature
/// rather than redefined here — it is the same postal address whether it is
/// read off the user document or managed through `/addresses`, and a second
/// definition would drift. What is *not* reusable is the write shape:
/// [Address] requires an id it does not have until the server assigns one,
/// and `PATCH` accepts a subset. Hence this.
///
/// Field names follow the API exactly. In particular the street line is
/// **`street`** — there is no `line1`/`line2` pair anywhere in this system.
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

  /// Pre-fills the form when editing an existing entry.
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

  /// The four fields the backend requires on create. Checked here so the
  /// form can disable its submit button rather than round-tripping for a 422
  /// the client could have predicted.
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
