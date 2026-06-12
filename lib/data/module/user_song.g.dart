// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSong _$UserSongFromJson(Map<String, dynamic> json) => UserSong(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fingerprintId: json['fingerprintId'] as String?,
      userId: (json['userId'] as num).toInt(),
      list: json['list'] as String?,
      delFlag: json['delFlag'] as String?,
      createBy: json['createBy'] as String?,
      createTime: json['createTime'] as String?,
      updateBy: json['updateBy'] as String?,
      updateTime: json['updateTime'] as String?,
      remark: json['remark'] as String?,
    );

Map<String, dynamic> _$UserSongToJson(UserSong instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fingerprintId': instance.fingerprintId,
      'userId': instance.userId,
      'list': instance.list,
      'delFlag': instance.delFlag,
      'createBy': instance.createBy,
      'createTime': instance.createTime,
      'updateBy': instance.updateBy,
      'updateTime': instance.updateTime,
      'remark': instance.remark,
    };
