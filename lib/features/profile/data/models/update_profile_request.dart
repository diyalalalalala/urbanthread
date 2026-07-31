import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateProfileRequest {
  const UpdateProfileRequest({this.name, this.phone});

  final String? name;

  final String? phone;

  bool get isEmpty => name == null && phone == null;

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
