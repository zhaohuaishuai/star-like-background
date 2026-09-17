import 'package:json_annotation/json_annotation.dart';
part 'user_song.g.dart';

@JsonSerializable()
class UserSong {
  final int id;
  final String name;
  final String? fingerprintId;
  final int? userId;
  final String? list;
  final String? delFlag;
  final String? createBy;
  final String? createTime;
  final String? updateBy;
  final String? updateTime;
  final String? remark;
  final String? posterUrl;

  UserSong({
    required this.id,
    required this.name,
    this.fingerprintId,
    this.userId,
    this.list,
    this.delFlag,
    this.createBy,
    this.createTime,
    this.updateBy,
    this.updateTime,
    this.remark,
    this.posterUrl,
  });

  copyWith({
    int? id,
    String? name,
    String? fingerprintId,
    int? userId,
    String? list,
    String? delFlag,
    String? createBy,
    String? createTime,
    String? updateBy,
    String? updateTime,
    String? remark,
    String? posterUrl,
  }) {
    return UserSong(
      id: id ?? this.id,
      name: name ?? this.name,
      fingerprintId: fingerprintId ?? this.fingerprintId,
      userId: userId ?? this.userId,
      list: list ?? this.list,
      delFlag: delFlag ?? this.delFlag,
      createBy: createBy ?? this.createBy,
      createTime: createTime ?? this.createTime,
      updateBy: updateBy ?? this.updateBy,
      updateTime: updateTime ?? this.updateTime,
      remark: remark ?? this.remark,
      posterUrl: posterUrl ?? this.posterUrl,
    );
  }

  factory UserSong.fromJson(Map<String, dynamic> json) =>
      _$UserSongFromJson(json);

  Map<String, dynamic> toJson() => _$UserSongToJson(this);
}
