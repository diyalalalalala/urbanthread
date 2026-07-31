import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'auth_models.g.dart';

@JsonSerializable(createToJson: false)
class AuthResponseModel {
  const AuthResponseModel({required this.user, required this.accessToken});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  final UserModel user;
  final String accessToken;
}

@JsonSerializable(createFactory: false)
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  final String name;
  final String email;

  final String password;

  final String? phone;

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class EmailRequest {
  const EmailRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => _$EmailRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class ResetPasswordRequest {
  const ResetPasswordRequest({required this.password});

  final String password;

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}
