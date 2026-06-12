import 'package:json_annotation/json_annotation.dart';
part 'active_member_params.g.dart';

@JsonSerializable()
class ActiveMemberParams {
  String email;
  String activeCode;
  String uuid;
  String code;

  ActiveMemberParams(
      {required this.email,
      required this.activeCode,
      required this.uuid,
      required this.code});

  factory ActiveMemberParams.fromJson(Map<String, dynamic> json) =>
      _$ActiveMemberParamsFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveMemberParamsToJson(this);
}
