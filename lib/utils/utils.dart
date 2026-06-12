import 'package:flutter/foundation.dart';
import '../api/api.dart';
import 'dart:convert';
import '../type/sgbType.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import '../storage/sgbStorage.dart';
import '../container/sgbContainer.dart';
import "package:get/get.dart";
import 'package:Shine_like_a_star/utils/setPlatfromTitle.dart'
    if (dart.library.html) 'package:Shine_like_a_star/utils/setWebTitle.dart';

SgbProvider api = new SgbProvider();

class Jutils {
  final SgbStorage sgbStorage = SgbStorage();
  static transitionIdBySgbData(String ids) async {
    api.baseUrl = api.basePath;
    var sgbRes = await api.getSgb(1, 1000);
    if (sgbRes.body != null) {
      var a = json.decode(sgbRes.bodyString as String);
      var b = SgbResponse.fromJson(a);
      if (b.code == 200) {
        List<SgbData> sgbList = b.data.rows.map(
          (e) {
            return SgbData.fromJson(e);
          },
        ).toList();
      }
    }
  }

  static Future<dynamic> deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        return build.androidId;
        // deviceName = build.model;
        // deviceVersion = build.version.toString();
        // identifier = build.androidId;
        //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        return data.identifierForVendor;
        // setState(() {
        //   deviceName = data.name;
        //   deviceVersion = data.systemVersion;
        //   identifier = data.identifierForVendor;
        // });//UUID for iOS
      }
    } catch (err) {
      var key = 'devId';
      var sgbStorage = Get.find<SgbContainer>().sgbStorage;

      var devId = sgbStorage.storage.read(key);
      if (devId == null) {
        // devId = Uuid().v4();
        devId = new DateTime.now().microsecondsSinceEpoch.toString();
        // sgbStorage.storage.write(key, devId);
      }
      return devId;
      print("这个是web平台");
    }
  }

  static setWebTitle(title) {
    setTitle(title);
  }

  static setWebDebug() {
    webDebug();
  }

  static bool isWebAnd() {
    return isAndroid();
  }

  static bool isWebIOS() {
    return isIOS();
  }

  static int webHisLength() {
    return webHistoryLength();
  }
}

class PlatformUtils {
  static bool _isWeb() {
    return kIsWeb == true;
  }

  static bool _isAndroid() {
    return _isWeb() ? false : Platform.isAndroid;
  }

  static bool _isIOS() {
    return _isWeb() ? false : Platform.isIOS;
  }

  static bool _isMacOS() {
    return _isWeb() ? false : Platform.isMacOS;
  }

  static bool _isWindows() {
    return _isWeb() ? false : Platform.isWindows;
  }

  static bool _isFuchsia() {
    return _isWeb() ? false : Platform.isFuchsia;
  }

  static bool _isLinux() {
    return _isWeb() ? false : Platform.isLinux;
  }

  static bool get isWeb => _isWeb();

  static bool get isAndroid => _isAndroid();

  static bool get isIOS => _isIOS();

  static bool get isMacOS => _isMacOS();

  static bool get isWindows => _isWindows();

  static bool get isFuchsia => _isFuchsia();

  static bool get isLinux => _isLinux();
}





