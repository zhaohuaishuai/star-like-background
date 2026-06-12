import 'package:json_annotation/json_annotation.dart';

part 'sgb_data.g.dart';

@JsonSerializable()
class SgbData {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'isad')
  final bool isad;

  @JsonKey(name: 'shiji_index')
  final int shijiIndex;

  @JsonKey(name: 'title')
  final String title;

   @JsonKey(name: 'xuhao')
  final num xuhao;

   @JsonKey(name: 'years')
  final String? years;

 

  SgbData({ 
    required this.id,
    required this.title,
    this.years,
    required this.isad,
 
    required this.shijiIndex,
    required this.xuhao
  });

  factory SgbData.fromJson(Map<String, dynamic> json) =>
      _$SgbDataFromJson(json);

  Map<String, dynamic> toJson() => _$SgbDataToJson(this);
}
