// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BibleContent _$BibleContentFromJson(Map<String, dynamic> json) => BibleContent(
      ID: (json['ID'] as num).toInt(),
      VolumeSN: (json['VolumeSN'] as num).toInt(),
      ChapterSN: (json['ChapterSN'] as num).toInt(),
      VerseSN: (json['VerseSN'] as num).toInt(),
      Lection: json['Lection'] as String,
    );

Map<String, dynamic> _$BibleContentToJson(BibleContent instance) =>
    <String, dynamic>{
      'ID': instance.ID,
      'VolumeSN': instance.VolumeSN,
      'ChapterSN': instance.ChapterSN,
      'VerseSN': instance.VerseSN,
      'Lection': instance.Lection,
    };
