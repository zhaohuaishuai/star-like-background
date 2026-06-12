// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
part 'user_song_detail.g.dart';

enum GeDanListType {
  /// 歌单赞美
  geDan,

  /// 经文
  jw
}

@JsonSerializable()
class UserSongDetail {
  final String id;
  final String mulu;
  final GeDanListType type;
  final String shijiName;
  final int ShijiTypeId;

  UserSongDetail({
    required this.id,
    required this.mulu,
    required this.type,
    required this.shijiName,
    required this.ShijiTypeId,
  });

  factory UserSongDetail.fromJson(Map<String, dynamic> json) =>
      _$UserSongDetailFromJson(json);

  Map<String, dynamic> toJson() => _$UserSongDetailToJson(this);
}
