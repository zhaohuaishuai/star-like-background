// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_search_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BibleSearchContent _$BibleSearchContentFromJson(Map<String, dynamic> json) =>
    BibleSearchContent(
      ID: (json['ID'] as num).toInt(),
      VolumeSN: (json['VolumeSN'] as num).toInt(),
      ChapterSN: (json['ChapterSN'] as num).toInt(),
      VerseSN: (json['VerseSN'] as num).toInt(),
      Lection: json['Lection'] as String,
      ShortName: json['ShortName'] as String,
    );

Map<String, dynamic> _$BibleSearchContentToJson(BibleSearchContent instance) =>
    <String, dynamic>{
      'ID': instance.ID,
      'VolumeSN': instance.VolumeSN,
      'ChapterSN': instance.ChapterSN,
      'VerseSN': instance.VerseSN,
      'Lection': instance.Lection,
      'ShortName': instance.ShortName,
    };
