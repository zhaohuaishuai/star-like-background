// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notice _$NoticeFromJson(Map<String, dynamic> json) => Notice(
      id: (json['noticeId'] as num).toInt(),
      title: json['noticeTitle'] as String,
      content: json['noticeContent'] as String,
      createTime: json['createTime'] as String,
      updateTime: json['updateTime'] as String?,
      noticeType: $enumDecode(_$NoticeTypeEnumEnumMap, json['noticeType']),
    );

Map<String, dynamic> _$NoticeToJson(Notice instance) => <String, dynamic>{
      'noticeId': instance.id,
      'noticeTitle': instance.title,
      'noticeContent': instance.content,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'noticeType': _$NoticeTypeEnumEnumMap[instance.noticeType]!,
    };

const _$NoticeTypeEnumEnumMap = {
  NoticeTypeEnum.notice: '1',
  NoticeTypeEnum.noticeBoard: '2',
  NoticeTypeEnum.webview: '3',
};
