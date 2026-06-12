// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sgb_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SgbData _$SgbDataFromJson(Map<String, dynamic> json) => SgbData(
      id: json['id'] as String,
      title: json['title'] as String,
      years: json['years'] as String?,
      isad: json['isad'] as bool,
      shijiIndex: (json['shiji_index'] as num).toInt(),
      xuhao: json['xuhao'] as num,
    );

Map<String, dynamic> _$SgbDataToJson(SgbData instance) => <String, dynamic>{
      'id': instance.id,
      'isad': instance.isad,
      'shiji_index': instance.shijiIndex,
      'title': instance.title,
      'xuhao': instance.xuhao,
      'years': instance.years,
    };
