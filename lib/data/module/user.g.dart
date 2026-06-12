// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      createBy: json['createBy'] as String?,
      createTime: json['createTime'] as String?,
      updateBy: json['updateBy'] as String?,
      updateTime: json['updateTime'] as String?,
      remark: json['remark'] as String?,
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String?,
      nickName: json['nickName'] as String?,
      email: json['email'] as String?,
      phonenumber: json['phonenumber'] as String?,
      sex: json['sex'] as String?,
      avatar: json['avatar'] as String?,
      registerIp: json['registerIp'] as String?,
      registerTerminal: (json['registerTerminal'] as num?)?.toInt(),
      birthday: json['birthday'] as String?,
      areaId: json['areaId'] as String?,
      password: json['password'] as String?,
      status: json['status'] as String?,
      delFlag: json['delFlag'] as String?,
      loginIp: json['loginIp'] as String?,
      loginDate: json['loginDate'] as String?,
      activeCode: json['activeCode'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'createBy': instance.createBy,
      'createTime': instance.createTime,
      'updateBy': instance.updateBy,
      'updateTime': instance.updateTime,
      'remark': instance.remark,
      'userId': instance.userId,
      'userName': instance.userName,
      'nickName': instance.nickName,
      'email': instance.email,
      'phonenumber': instance.phonenumber,
      'sex': instance.sex,
      'avatar': instance.avatar,
      'registerIp': instance.registerIp,
      'registerTerminal': instance.registerTerminal,
      'birthday': instance.birthday,
      'areaId': instance.areaId,
      'password': instance.password,
      'status': instance.status,
      'delFlag': instance.delFlag,
      'loginIp': instance.loginIp,
      'loginDate': instance.loginDate,
      'activeCode': instance.activeCode,
    };
