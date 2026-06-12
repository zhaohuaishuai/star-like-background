import 'package:json_annotation/json_annotation.dart';

part 'register_params.g.dart';

@JsonSerializable()
class RegisterParams {
  final String email;
  final String password;
  final String uuid;
  final String code;
  final String confirmPassword;

  /// 注册终端  0 web 1 android 2 ios
  final int registerTerminal;

  RegisterParams({
    required this.email,
    required this.password,
    required this.uuid,
    required this.code,
    required this.confirmPassword,
    required this.registerTerminal,
  });

  factory RegisterParams.fromJson(Map<String, dynamic> json) =>
      _$RegisterParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterParamsToJson(this);
}
