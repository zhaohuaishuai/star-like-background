// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      ChapterSN: (json['ChapterSN'] as num).toInt(),
      VerseNumber: (json['VerseNumber'] as num).toInt(),
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'ChapterSN': instance.ChapterSN,
      'VerseNumber': instance.VerseNumber,
    };
