import 'package:json_annotation/json_annotation.dart';
part 'login_params.g.dart';

@JsonSerializable()
class LoginParams {
  final String email;
  final String password;
  final String uuid;
  final String code;

  LoginParams({
    required this.email,
    required this.password,
    required this.uuid,
    required this.code,
  });

  // copyWith 方法
  LoginParams copyWith({
    String? email,
    String? password,
    String? uuid,
    String? code,
  }) {
    return LoginParams(
      email: email ?? this.email,
      password: password ?? this.password,
      uuid: uuid ?? this.uuid,
      code: code ?? this.code,
    );
  }

  factory LoginParams.fromJson(Map<String, dynamic> json) =>
      _$LoginParamsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginParamsToJson(this);
}
