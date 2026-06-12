import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  String? createBy;
  String? createTime;
  String? updateBy;
  String? updateTime;
  String? remark;
  int userId;
  String? userName;
  String? nickName;
  String? email;
  String? phonenumber;
  String? sex;
  String? avatar;
  String? registerIp;
  int? registerTerminal;
  String? birthday;
  String? areaId;
  String? password;
  String? status;
  String? delFlag;
  String? loginIp;
  String? loginDate;
  String? activeCode;

  User({
    this.createBy,
    this.createTime,
    this.updateBy,
    this.updateTime,
    this.remark,
    required this.userId,
    this.userName,
    this.nickName,
    this.email,
    this.phonenumber,
    this.sex,
    this.avatar,
    this.registerIp,
    this.registerTerminal,
    this.birthday,
    this.areaId,
    this.password,
    this.status,
    this.delFlag,
    this.loginIp,
    this.loginDate,
    this.activeCode,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
