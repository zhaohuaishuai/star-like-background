import 'package:dio/dio.dart' as DDio;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../type/sgbType.dart';
import '../type/appVersion.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/utils.dart';

class SgbProvider extends GetConnect {

 @override
 void onInit() {

    httpClient.timeout = Duration(seconds: 10);


    // 设备指纹：首次启动生成 UUID 并持久化
    String? deviceId = getStorage.read('device_fingerprint_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      if (deviceId != null) {
        getStorage.write('device_fingerprint_id', deviceId);
      }
    }

    // 添加请求拦截器，自动注入 fingerprintId 到请求头
    httpClient.addRequestModifier<void>((request) {
      if (deviceId != null) {
        request.headers['fingerprintId'] = deviceId!;
        request.headers['Fingerprintid'] = deviceId!;
      }
      return request;
    });

    // TODO: implement onInit
    super.onInit();
  }


  GetStorage getStorage = GetStorage();
  var devPath = 'http://10.0.2.2:7001';
  var webdevPath = '/';
  var isProd = true;
  // var prodPath = 'https://game.top237.top';
  var prodPath = 'https://api.top237.top/ry-api';
  // var prodPath = 'http://10.0.2.2:8686';
  get basePath {
    if (PlatformUtils.isAndroid || PlatformUtils.isIOS) {
      if (isProd) {
        return prodPath;
      } else {
        return devPath;
      }
    }
    if (PlatformUtils.isWeb) {
      if (isProd) {
        return prodPath;
      } else {
        return 'http://127.0.0.1:7001';
      }
    }
  }

  // 缓存一切的请求值
  chche<T>(key, path) async {

    var shijiList = getStorage.read(key);
    if (shijiList == null) {
      try {
        var res = await get(path);
        if(res.body?["code"] != 200){ 
          throw Exception(res.body["msg"] ?? "请求失败");
        }
        if(res.bodyString!=null && res.body["code"]== 200){
          await getStorage.write(key, res.body);
        }
        return Response(body: res.body, bodyString: res.bodyString);
      } catch (err) {
        return Response(body: null, bodyString: null);
      }
    }
    return Response(body: shijiList, bodyString: json.encode(shijiList));
  }
  //获取诗集类型
  getShiji() async {
    const key = "/start/shijidb/list?pageNum=1&pageSize=10000&isUpper=1";
    try {
      var res = await chche<List<dynamic>>(key, '$key');
      print("获取专辑列表：${res.body}");
      if(res.body != null){
        return res;
      }
      var sgbDataJson = await rootBundle.loadString('lib/json/sgbdb.json');
      print("🐛:请求sgb专辑数据链接是${key}超时请求错误");
      print("👉:使用本地缓存sgbdb.json的数据-->${sgbDataJson}");
      return Response(body: json.decode(sgbDataJson), bodyString: sgbDataJson);

    }catch(err){
      print("🐛:${key}发生了错误");
      print(err.toString());
    }

    // return await get(key);
  }

  //获取原创专辑
  getOriginalType() async {
    const key = "/start/shijidb/list?pageNum=1&pageSize=10000&isUpper=1&type=original_type";
    return await chche<List<dynamic>>(key, '$key');
    // return await get(key);
  }


  // 获取的有诗歌本
  getSgb(int page, int size) async {
    var key = "sgbAllList";
    var shijiList = getStorage.read(key);
    var url = "https://oss.top237.top/npm/static/js/db.json";
    if (shijiList == null) {
      try {
        DDio.Dio dio = DDio.Dio(
             DDio.BaseOptions(
               connectTimeout: const Duration(seconds: 2),
               receiveTimeout: const Duration(seconds: 5),
               sendTimeout: const Duration(seconds: 5),
             )
        );

        DDio.Response<dynamic> res = await dio.get(url);
        if(res.data != null){
           print("👉:缓存sgb数据");
          await getStorage.write(key, res.data);
        }
        print("🎉:版本更新sgb数据更新成功");
        return Response(body: res.data, bodyString: json.encode(res.data));
      } catch (err) {
        var sgbDataJson = await rootBundle.loadString('lib/json/db.json');
        print("🐛:请求sgb数据链接是${url}超时请求错误");
        print("👉:使用本地缓存sgb.json的数据");
        return Response(body: json.decode(sgbDataJson), bodyString: sgbDataJson);
      }
    }
    print("👉:使用缓存sgb数据");
    return Response(body: shijiList, bodyString: json.encode(shijiList));
  }

  Future<Version> getVersion() async {
    var key = '/start/zanmei/version';
    try {
      var res = await get(key);
      if (res.body?['code'] == 200) {
        var b = Version(version: res.body['msg']);
        return b;
      } else {
        return Version(
          id: '0',
        );
      }
    } catch (err) {
      return Version(
        id: '0',
      );
    }
  }

  Future<AppVersion?> getAppVersion() async {
    var key = "/start/appversion/new";
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      var res = await get(key);
      if (res.body != null) {
        // var appVersionRes = AppVersionRes.fromJson(res.body);
        if (res.body["code"] == 200) {
          if (res.body["data"] != null) {
            AppVersion appVersion =  AppVersion.fromJson(res.body["data"]);
            if (appVersion.version != packageInfo.version) {
              return appVersion;
            } else {
              if (PlatformUtils.isWeb) {
                return appVersion;
              }
              return null;
            }
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    } catch (err) {
      print("请求App版本出错$err");
      return null;
    }
    return null;
  }

  Future<Response<dynamic>> getVersions(int page, int? limit) async {
    var key = '/start/version/list?pageNum=${page}&pageSize=${limit}';
    return get(key);
  }

  Future<Response> getSongList(String type) async {
    var key = '/api/gedan/getRecommend';
    try {
      var res = await get(key, query: {type: type});

      if (res == null) {
        throw "网络出现问题";
      }
      return res;
    } catch (err) {
      print("err-->>$err");
      return Response();
    }
  }

  Future<Response> getNoticeList() async {
    var key = basePath + '/system/notice/list?status=0';
    try {
      var res = await get(key);

      return res;
    } catch (err) {
      print("🐛: 获取首页通知接口失败 $err");
      return Response();
    }
  }


  Future<Response> getFileMd5(String url) async {
    var key = basePath + '/start/shijidb/md5?url=' + url;
    print("key-->" + key);
    try {
      var res = await get(key);

      return res;
    } catch (err) {
      print("err-->>$err");
      return Response();
    }
  }





}
