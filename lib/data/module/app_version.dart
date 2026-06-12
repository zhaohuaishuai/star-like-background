import 'package:json_annotation/json_annotation.dart';
part 'app_version.g.dart';

@JsonSerializable()
class AppVersion { 
  final int id;
  final String version;
  final String context;
  final String downpath;
 

  AppVersion({  
    required this.id,
    required this.version,
    required this.context,
    required this.downpath, 
  });
  factory AppVersion.fromJson(Map<String, dynamic> json) =>
      _$AppVersionFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionToJson(this);
   
}