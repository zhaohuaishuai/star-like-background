import 'package:json_annotation/json_annotation.dart';

part 'notice.g.dart';

enum NoticeTypeEnum {
  /// 通知
  @JsonValue('1')
  notice,
  /// 公告
  @JsonValue('2')
  noticeBoard,
  /// Webveiw 
  @JsonValue('3')
  webview,
}

@JsonSerializable()
class Notice {
  @JsonKey(name: 'noticeId')
  final int id;

  @JsonKey(name: 'noticeTitle')
  final String title;

  @JsonKey(name: 'noticeContent')
  final String content;

  @JsonKey(name: 'createTime')
  final String createTime;

  @JsonKey(name: 'updateTime')
  final String? updateTime;

  final NoticeTypeEnum noticeType;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createTime,
    this.updateTime,
    required this.noticeType,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => _$NoticeFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeToJson(this);
}
