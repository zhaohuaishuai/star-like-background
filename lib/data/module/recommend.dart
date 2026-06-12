import 'package:json_annotation/json_annotation.dart';

part 'recommend.g.dart';

@JsonSerializable()
class Recommend {
  @JsonKey(name: 'id')
  final num id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'linkUrl')
  final String linkUrl;

  @JsonKey(name: 'imgUrl')
  final String imgUrl;

  Recommend({
    required this.id,
    required this.title,
    required this.linkUrl,
    required this.imgUrl,
  });

  factory Recommend.fromJson(Map<String, dynamic> json) =>
      _$RecommendFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendToJson(this);
}
