// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_member_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveMemberParams _$ActiveMemberParamsFromJson(Map<String, dynamic> json) =>
    ActiveMemberParams(
      email: json['email'] as String,
      activeCode: json['activeCode'] as String,
      uuid: json['uuid'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$ActiveMemberParamsToJson(ActiveMemberParams instance) =>
    <String, dynamic>{
      'email': instance.email,
      'activeCode': instance.activeCode,
      'uuid': instance.uuid,
      'code': instance.code,
    };
