// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:m/features/pages/bible/module/chapter.dart';
part 'bible_dict.g.dart';
@JsonSerializable()
class BibleDict {
  final List<Chapter> children;
  // final List<String> searchNames;
  final int NewOrOld;
  final String? ShortEnName;
  final String FullName;
  final String PinYin;
  final String ShortName;
  final int ChapterNumber;
  final int VolumeSN;
  List<String> get searchNames {
    return [
      FullName,
      PinYin,
      ShortName,
    ];
  }

  BibleDict({
    required this.children,
    // required this.searchNames,
    required this.NewOrOld,
      this.ShortEnName,
    required this.FullName,
    required this.PinYin,
    required this.ShortName,
    required this.ChapterNumber,
    required this.VolumeSN,
  });

  factory BibleDict.fromJson(Map<String, dynamic> json) =>
      _$BibleDictFromJson(json);

  Map<String, dynamic> toJson() => _$BibleDictToJson(this);
}
