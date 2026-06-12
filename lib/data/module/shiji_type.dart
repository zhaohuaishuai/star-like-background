import 'package:json_annotation/json_annotation.dart';

part 'shiji_type.g.dart';

@JsonSerializable()
class ShijiType {
  final int id;
  final String name;
  final int isUpper;
  final String? thumbnails;
  final int starOrder;
  final String type;

  ShijiType({
    required this.id,
    required this.name,
    required this.isUpper,
    this.thumbnails,
    required this.starOrder,
    required this.type,
  });

  factory ShijiType.fromJson(Map<String, dynamic> json) =>
      _$ShijiTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ShijiTypeToJson(this);
}
