import 'package:json_annotation/json_annotation.dart';

part 'dmt_url.g.dart';

@JsonSerializable()
class DmtUrl {
  final String? id;
  final String? adUrl;
  final String? gepuUrl;
  final String? pptUrl;
  final String? lyric;
  final String? teachingUrl;
  final String? lrc;
  final String? enGePuUrl;
  final String? banZouUrl;
  final String? assLyric;
  DmtUrl({
    this.id,
    this.adUrl,
    this.gepuUrl,
    this.pptUrl,
    this.lyric,
    this.teachingUrl,
    this.lrc,
    this.enGePuUrl,
    this.banZouUrl,
    this.assLyric
  });

  factory DmtUrl.fromJson(Map<String, dynamic> json) => _$DmtUrlFromJson(json);

  Map<String, dynamic> toJson() => _$DmtUrlToJson(this);
}
