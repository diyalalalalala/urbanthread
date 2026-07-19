import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

/// Body for `PATCH /users/me`.
///
/// The validator whitelists exactly `name` and `phone` and silently discards
/// every other key — sending `email` or `role` here looks like it worked and
/// changes nothing. Nulls are omitted rather than serialised, because an
/// explicit `null` would fail the length/pattern checks, and a body that
/// carries no effective change is answered with a 400.
@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateProfileRequest {
  const UpdateProfileRequest({this.name, this.phone});

  /// 2..80 characters.
  final String? name;

  /// Must match `/^[+]?[\d\s().-]{7,20}$/`.
  final String? phone;

  bool get isEmpty => name == null && phone == null;

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
