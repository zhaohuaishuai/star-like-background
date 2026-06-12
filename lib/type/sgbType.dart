import 'package:flutter/material.dart';

class Dmturl {
  final String id;
  final String lyric;
  final bool islyric;
  final String teachingUrl;
  final bool istea;
  final String adUrl;
  final bool isad;
  final String pptUrl;
  final bool isppt;
  final String gepuUrl;
  final String gepu;
  final bool isgepu;
  //用于搜索时出来结果的歌词
  List<RichText>? splitLyric;
  Dmturl(
      {required this.adUrl,
      required this.gepu,
      required this.gepuUrl,
      required this.id,
      required this.isad,
      required this.isgepu,
      required this.islyric,
      required this.isppt,
      required this.istea,
      required this.lyric,
      required this.pptUrl,
      required this.teachingUrl,
      this.splitLyric});
  factory Dmturl.fromJsion(Map<String, dynamic> json) {
    return Dmturl(
        adUrl: json["adUrl"],
        gepu: json["gepuUrl"],
        gepuUrl: json["gepuUrl"],
        id: json["id"],
        isad: json["adUrl"] != "",
        isgepu: json["gepuUrl"] != "",
        islyric: json["lyric"] != "",
        isppt: json["pptUrl"] != "",
        istea: json["teachingUrl"] != "",
        lyric: json["lyric"] ?? '',
        pptUrl: json["pptUrl"],
        teachingUrl: json["teachingUrl"] ?? '',
        splitLyric: json['splitLyric'] ?? []);
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "lyric": lyric,
    "islyric": islyric,
    "teachingUrl": teachingUrl,
    "istea": istea,
    "adUrl": adUrl,
    "isad": isad,
    "pptUrl": pptUrl,
    "isppt": isppt,
    "gepuUrl": gepuUrl,
    "gepu": gepu,
    "isgepu": isgepu,

  };
}

class SgbData {
  final String id;

  final bool isuppered;

  final String full_title;

  final int isupper;

  final int shiji_index;

  final String? shiji_title;

  final int xuhao;

  final String title;

  final String years;

  final Dmturl dmturl;

  SgbData(
      {
      required this.id,
      required this.full_title,
      required this.isupper,
      required this.isuppered,
      required this.shiji_index,
      required this.title,
      required this.xuhao,
      required this.years,
      required this.dmturl,
      this.shiji_title,
      });
    factory SgbData.fromJson(Map<String, dynamic> json) {
      var dmturl = Dmturl.fromJsion(json['dmturl']);
      return SgbData(
          id: json["id"],
          full_title: json["full_title"],
          isupper: 1,
          isuppered: true,
          shiji_index: json["shiji_index"],
          title: json["title"],
          xuhao: json["xuhao"],
          years: json["years"] == null ? "" : json["years"],
          shiji_title: json["shiji_title"]?? "",
          dmturl: dmturl);
    }
    Map<String, dynamic> toJson() {
      return {
                  "id": id,
                "isuppered": isuppered,
                "full_title": full_title,
                "isupper": isupper,
                "shiji_index": shiji_index,
                "xuhao": xuhao,
                "title": title,
                "years": years,
                "dmturl": dmturl.toJson(),
              };
    }
}

class SgbResponse {
  final int code;
  final SgbDataWrap data;
  SgbResponse({required this.code, required this.data});
  factory SgbResponse.fromJson(Map<String, dynamic> json) {
    var data = SgbDataWrap.fromJson(json['data']);
    return SgbResponse(code: json['code'], data: data);
  }
}

class SgbDataWrap {
  final int count;
  final List<dynamic> rows;
  final int page;
  final int size;
  final int pages;
  SgbDataWrap(
      {required this.count,
      required this.page,
      required this.pages,
      required this.rows,
      required this.size});
  factory SgbDataWrap.fromJson(Map<String, dynamic> json) {
    var rows = json['rows'];

    return SgbDataWrap(
        count: json['count'],
        page: json['page'],
        rows: rows,
        size: json['size'],
        pages: json['pages']);
  }
}

class Live {
  final String id;
  final String name;
  final String pushPath;
  final String pushCode;
  final String teacherId;
  final String startTime;
  Live(
      {required this.id,
      required this.name,
      required this.pushCode,
      required this.pushPath,
      required this.teacherId,
      required this.startTime});
  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
        id: json['id'],
        name: json['name'],
        pushCode: json['pushCode'],
        pushPath: json['pushPath'],
        teacherId: json['teacherId'],
        startTime: json['startTime']);
  }
}

enum SgbTypeEnum {
  original_type,sgb_type
}
// 曲目类型
class SgbDb {
  int? id;
  String? name;
  bool? isUpper;
  String? thumbnails;
  String? type;
  List<SgbData>? list;
  SgbDb({this.id, this.name, this.isUpper,this.list});
  SgbDb.fromJson(Map<String, dynamic> json) {


    id = json['id'];
    name = json['name'];
    isUpper = json['isUpper'] == 1;
    thumbnails = json['thumbnails'];
    list = json['list'];


    type = json['type'] ;

  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['isUpper'] = this.isUpper;
    data['thumbnails'] = this.thumbnails;
    data['type'] = this.type;
    return data;
  }
  setList(List<SgbData> val){
    this.list = val;
  }
}

// 版本
class Version {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? context;
  String? version;
  bool? isShow;
  Version(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.context,
      this.version,
      this.isShow});

  Version.fromJson(Map<String, dynamic> json) {
    id = json['id'] == null ? "abdkdc33323" : json['id'].toString();
    createdAt = json['createTime'];
    updatedAt = json['createTime'];
    context = json['context'];
    version = json['version'];
    isShow = json['isShow'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createTime'] = this.createdAt;
    data['updateTime'] = this.updatedAt;
    data['context'] = this.context;
    data['version'] = this.version;
    data['isShow'] = this.isShow;
    return data;
  }


}

// 历史记录
class History {
  String? id;
  String? createDate;
  int? playCount;

  History({this.id, this.createDate, this.playCount});

  History.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createDate = json['create_date'];
    playCount = json['playCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['create_date'] = this.createDate;
    data['playCount'] = this.playCount;
    return data;
  }
}

// 歌单类型
class SongListData {
  String? id;
  String? title;
  String? userId;
  String? ids;
  String? content;
  String? coverImg;
  bool? isPut;
  String? createdAt;
  String? updatedAt;
  SongListData(
      {
      this.id,
      this.title,
      this.userId,
      this.ids,
      this.content,
      this.coverImg,
      this.isPut,
      this.createdAt,
      this.updatedAt
    });

  SongListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    userId = json['userId'];
    ids = json['ids'];
    content = json['content'];
    coverImg = json['coverImg'];
    isPut = json['isPut'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['userId'] = this.userId;
    data['ids'] = this.ids;
    data['content'] = this.content;
    data['coverImg'] = this.coverImg;
    data['isPut'] = this.isPut;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

// 歌单请求body

class SongListBody {
  int? status;
  String? message;
  List<SongListData>? data;

  SongListBody({this.status, this.message, this.data});

  SongListBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SongListData>[];
      json['data'].forEach((v) {
        data!.add(new SongListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    } else {
      data['data'] = [];
    }
    return data;
  }
}

// 页面名称路由
enum RouteName {
  firstPage,
  playerPage,
  playerTypeList,
  SongListPage,
  shijiPage,
  SearchPage,
  VersionPage,
  GeDanEditPage,
  GePuPage,
  GeCiPage,
  SharePlayerPlage,
  TPController,
  GuitarTuning,
  SgbList,
  SgbAppPage,
  SgbPlayerV3Page,
  MyGeDan,
  MyGeDanDetail,
  TichTextPage,
  BiblePage,
  OriginalPoetryPage,
  OriginalPoetryDetail,
}

extension RoteNames on RouteName {
  String get value {
    switch (this) {
      case RouteName.firstPage:
        return '/';
      case RouteName.playerPage:
        return '/playerPage';
      case RouteName.playerTypeList:
        return '/playerTypeList';
      case RouteName.SongListPage:
        return '/SongListPage';
      case RouteName.shijiPage:
        return '/shijiPage';
      case RouteName.SearchPage:
        return '/searchPage';
      case RouteName.VersionPage:
        return '/versionPage';
      case RouteName.GeDanEditPage:
        return '/GeDanEditPage';
      case RouteName.GePuPage:
        return '/GePuPage';
      case RouteName.GeCiPage:
        return '/GeCiPage';
      case RouteName.SharePlayerPlage:
        return '/SharePlayerPlage';
      case RouteName.TPController:
        return '/TPController';
      case RouteName.GuitarTuning:
        return '/GuitarTuning';
      case RouteName.SgbList:
        return '/SgbList';
      case RouteName.SgbAppPage:
        return '/SgbAppPage';
      case RouteName.SgbPlayerV3Page:
        return '/SgbPlayerV3Page';
      case RouteName.MyGeDan:
        return '/myGeDan';
      case RouteName.MyGeDanDetail:
        return '/MyGeDanDetail';
      case RouteName.TichTextPage:
        return '/TichTextPage';
      case RouteName.BiblePage:
        return '/BiblePage';
      case RouteName.OriginalPoetryPage:
        return '/OriginalPoetryPage';
      case RouteName.OriginalPoetryDetail:
        return '/OriginalPoetryDetail';
    }
  }
}

// 返回按钮类型

enum BackBtnType {
  home,
  back,
}


class Notice {
  String? createBy;
  String? createTime;
  String? updateBy;
  String? updateTime;
  dynamic remark;
  int? noticeId;
  String? noticeTitle;
  String? noticeType;
  String? noticeContent;
  String? status;

  Notice({
    this.createBy,
    this.createTime,
    this.updateBy,
    this.updateTime,
    this.remark,
    this.noticeId,
    this.noticeTitle,
    this.noticeType,
    this.noticeContent,
    this.status,
  });

  Notice.fromJson(Map<String, dynamic> json) {
    createBy = json['createBy'];
    createTime = json['createTime'];
    updateBy = json['updateBy'];
    updateTime = json['updateTime'];
    remark = json['remark'];
    noticeId = json['noticeId'];
    noticeTitle = json['noticeTitle'];
    noticeType = json['noticeType'];
    noticeContent = json['noticeContent'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createBy'] = this.createBy;
    data['createTime'] = this.createTime;
    data['updateBy'] = this.updateBy;
    data['updateTime'] = this.updateTime;
    data['remark'] = this.remark;
    data['noticeId'] = this.noticeId;
    data['noticeTitle'] = this.noticeTitle;
    data['noticeType'] = this.noticeType;
    data['noticeContent'] = this.noticeContent;
    data['status'] = this.status;
    return data;
  }
}