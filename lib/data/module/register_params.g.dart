// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterParams _$RegisterParamsFromJson(Map<String, dynamic> json) =>
    RegisterParams(
      email: json['email'] as String,
      password: json['password'] as String,
      uuid: json['uuid'] as String,
      code: json['code'] as String,
      confirmPassword: json['confirmPassword'] as String,
      registerTerminal: (json['registerTerminal'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterParamsToJson(RegisterParams instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'uuid': instance.uuid,
      'code': instance.code,
      'confirmPassword': instance.confirmPassword,
      'registerTerminal': instance.registerTerminal,
    };
