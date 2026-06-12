// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
      id: json['id'] as String,
      fullTitle: json['full_title'] as String,
      shijiIndex: (json['shiji_index'] as num).toInt(),
      xuhao: (json['xuhao'] as num).toInt(),
      title: json['title'] as String,
      years: json['years'] as String?,
      shijiname: json['shijiname'] as String,
      dmtUrl: DmtUrl.fromJson(json['dmturl'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'id': instance.id,
      'full_title': instance.fullTitle,
      'shiji_index': instance.shijiIndex,
      'xuhao': instance.xuhao,
      'title': instance.title,
      'years': instance.years,
      'shijiname': instance.shijiname,
      'dmturl': instance.dmtUrl,
    };
