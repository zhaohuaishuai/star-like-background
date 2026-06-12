// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersion _$AppVersionFromJson(Map<String, dynamic> json) => AppVersion(
      id: (json['id'] as num).toInt(),
      version: json['version'] as String,
      context: json['context'] as String,
      downpath: json['downpath'] as String,
    );

Map<String, dynamic> _$AppVersionToJson(AppVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'context': instance.context,
      'downpath': instance.downpath,
    };
