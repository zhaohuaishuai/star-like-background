// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_dict.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BibleDict _$BibleDictFromJson(Map<String, dynamic> json) => BibleDict(
      children: (json['children'] as List<dynamic>)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      NewOrOld: (json['NewOrOld'] as num).toInt(),
      ShortEnName: json['ShortEnName'] as String?,
      FullName: json['FullName'] as String,
      PinYin: json['PinYin'] as String,
      ShortName: json['ShortName'] as String,
      ChapterNumber: (json['ChapterNumber'] as num).toInt(),
      VolumeSN: (json['VolumeSN'] as num).toInt(),
    );

Map<String, dynamic> _$BibleDictToJson(BibleDict instance) => <String, dynamic>{
      'children': instance.children,
      'NewOrOld': instance.NewOrOld,
      'ShortEnName': instance.ShortEnName,
      'FullName': instance.FullName,
      'PinYin': instance.PinYin,
      'ShortName': instance.ShortName,
      'ChapterNumber': instance.ChapterNumber,
      'VolumeSN': instance.VolumeSN,
    };
