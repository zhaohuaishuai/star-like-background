// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_song_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSongDetail _$UserSongDetailFromJson(Map<String, dynamic> json) =>
    UserSongDetail(
      id: json['id'] as String,
      mulu: json['mulu'] as String,
      type: $enumDecode(_$GeDanListTypeEnumMap, json['type']),
      shijiName: json['shijiName'] as String,
      ShijiTypeId: (json['ShijiTypeId'] as num).toInt(),
    );

Map<String, dynamic> _$UserSongDetailToJson(UserSongDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mulu': instance.mulu,
      'type': _$GeDanListTypeEnumMap[instance.type]!,
      'shijiName': instance.shijiName,
      'ShijiTypeId': instance.ShijiTypeId,
    };

const _$GeDanListTypeEnumMap = {
  GeDanListType.geDan: 'geDan',
  GeDanListType.jw: 'jw',
};
