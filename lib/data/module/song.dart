import 'package:json_annotation/json_annotation.dart';
import 'dmt_url.dart';
part 'song.g.dart';

@JsonSerializable()
class Song {
  final String id;
  @JsonKey(name: 'full_title')
  final String fullTitle;
  @JsonKey(name: 'shiji_index')
  final int shijiIndex;
  final int xuhao;
  final String title;
  final String? years;

  final String shijiname;
  @JsonKey(name: 'dmturl')
  final DmtUrl dmtUrl;

  Song({
    required this.id,
    required this.fullTitle,
    required this.shijiIndex,
    required this.xuhao,
    required this.title,
    this.years,
    required this.shijiname,
    required this.dmtUrl,
  });

  copyWith({
    String? id,
    String? fullTitle,
    int? shijiIndex,
    int? xuhao,
    String? title,
    String? years,
    String? shijiname,
    DmtUrl? dmtUrl,
  }) {
    return Song(
      id: id ?? this.id,
      fullTitle: fullTitle ?? this.fullTitle,
      shijiIndex: shijiIndex ?? this.shijiIndex,
      xuhao: xuhao ?? this.xuhao,
      title: title ?? this.title,
      years: years ?? this.years,
      shijiname: shijiname ?? this.shijiname,
      dmtUrl: dmtUrl ?? this.dmtUrl,
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}
