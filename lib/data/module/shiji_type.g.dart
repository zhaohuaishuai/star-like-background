// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shiji_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShijiType _$ShijiTypeFromJson(Map<String, dynamic> json) => ShijiType(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isUpper: (json['isUpper'] as num).toInt(),
      thumbnails: json['thumbnails'] as String?,
      starOrder: (json['starOrder'] as num).toInt(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$ShijiTypeToJson(ShijiType instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isUpper': instance.isUpper,
      'thumbnails': instance.thumbnails,
      'starOrder': instance.starOrder,
      'type': instance.type,
    };
