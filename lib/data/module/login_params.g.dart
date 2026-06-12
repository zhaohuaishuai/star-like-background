// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginParams _$LoginParamsFromJson(Map<String, dynamic> json) => LoginParams(
      email: json['email'] as String,
      password: json['password'] as String,
      uuid: json['uuid'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$LoginParamsToJson(LoginParams instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'uuid': instance.uuid,
      'code': instance.code,
    };
