class AppVersionRes {
  int? code;
  String? message;
  Data? data;

  AppVersionRes({this.code, this.message, this.data});

  AppVersionRes.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? count;
  List<AppVersion>? rows;
  Data({this.count, this.rows});
  Data.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['rows'] != null) {
      rows = <AppVersion>[];
      json['rows'].forEach((v) {
        rows!.add(new AppVersion.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.rows != null) {
      data['rows'] = this.rows!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AppVersion {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? context;
  String? version;
  bool? isShow;
  String? downpath;

  AppVersion(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.context,
      this.version,
      this.isShow,
      this.downpath});

  AppVersion.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    context = json['context'];
    version = json['version'];
    isShow = json['isShow'] == 1;
    downpath = json['downpath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['context'] = this.context;
    data['version'] = this.version;
    data['isShow'] = this.isShow;
    data['downpath'] = this.downpath;
    return data;
  }
}
