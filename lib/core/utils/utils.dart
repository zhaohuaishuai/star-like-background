import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage_ohos/flutter_secure_storage_ohos.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/data/services/global.dart';
import 'package:m/data/services/metronome.dart';
import 'package:m/data/services/sgb.dart';
import 'package:m/data/services/star_player.dart';
import 'package:m/data/services/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import 'package:get_storage/get_storage.dart' as get_storage;

class Utils {
  static String padZerow(num value) {
    return value.toString().padLeft(3, '0');
  }

  //时间日期格式化 从头定义一个简单的格式化函数
  static String simplyFormat({required DateTime time, bool dateOnly = false}) {
    String year = time.year.toString();

    // 如果月份是 1 到 9，则在左侧添加 "0"
    String month = time.month.toString().padLeft(2, '0');

    // 如果日期是 1 到 9，则在左侧添加 "0"
    String day = time.day.toString().padLeft(2, '0');

    // 如果小时是 1 到 9，则在左侧添加 "0"
    String hour = time.hour.toString().padLeft(2, '0');

    // 如果分钟是 1 到 9，则在左侧添加 "0"
    String minute = time.minute.toString().padLeft(2, '0');

    // 如果秒数是 1 到 9，则在左侧添加 "0"
    String second = time.second.toString().padLeft(2, '0');

    // 如果只需要年份、月份和日期
    if (dateOnly == false) {
      return '$year-$month-$day $hour:$minute:$second';
    }

    // 返回 "yyyy-MM-dd" 格式
    return '$year-$month-$day';
  }

  static Future<void> showToast(String message,
      [ToastStatusEnum status = ToastStatusEnum.info,
      Duration duration = const Duration(seconds: 2)]) async {
    Toast.showToast(message, status, duration);
  }

  static Widget loading() {
    return Center(
      child: CircularProgressIndicator(
        color: StarThemeData.primaryColor,
      ),
    );
  }

  static Future<ShareResult> shareUrl(String url) async {
    ShareResult res =
        await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));

    if (res.status == ShareResultStatus.unavailable ||
        res.status == ShareResultStatus.success) {
      showToast('分享成功'.tr);
    }
    return res;
  }

  static Future<void> shareText(String text) async {
    ShareResult res = await SharePlus.instance.share(ShareParams(text: text));

    if (res.status == ShareResultStatus.unavailable ||
        res.status == ShareResultStatus.success) {
      showToast('分享成功'.tr);
    }
  }

  static Future<void> firstStartServices() async {
    await Get.putAsync<GlobalService>(() => GlobalService().init());
    await Get.putAsync<SgbService>(() => SgbService().init());
    await Get.putAsync<StarPlayer>(() => StarPlayer().init());
    await Get.putAsync<UserService>(() => UserService().init());
    await Get.putAsync<MetronomeService>(() => MetronomeService().init());
  }

  /// 反色处理
  static Uint8List invertColor(Uint8List imageBytes) {
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        Pixel pixel = image.getPixel(x, y);
        num red = 255 - pixel.r;
        num green = 255 - pixel.g;
        num blue = 255 - pixel.b;
        num alpha = pixel.a;
        img.Color color = img.ColorInt32.rgba(
            red.toInt(), green.toInt(), blue.toInt(), alpha.toInt());
        image.setPixel(x, y, color);
      }
    }
    return img.encodePng(image);
  }

  static Future<dynamic> testNetWork() async {
    return await Dio().get('https://www.cloudflare.com/cdn-cgi/trace');
  }

  static Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// 获取当前版本
  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }
}

class GetStorage {
  static bool get isUseGetStorage =>
      kIsWeb || Platform.isIOS || Platform.isAndroid;
  // 播放模式
  static const String playMode = '_play_mode';
  // 排序字段
  static const String sort = '_sort';
  // 本地语言
  static const String local = '_local';

  // 夜间模式
  static const String isDarkMode = '_isDarkMode';

  // 歌单类型
  static const String songListType = '_songListType';
  // 赞美id
  static const String praiseId = '_songId';
  // 歌单ID
  static const String praiseListId = '_songListId';

  // 搜索历史
  static const String searchHistory = '_searchHistory';

  // token
  static const String token = '_token';

  static const String version = '_version';

  // 首次启动标志
  static const String notFirstStart = '_notFirstStart';

  static const storage = FlutterSecureStorage();

  static init() async {
    if (isUseGetStorage) {
      await get_storage.GetStorage.init();
    }
  }

  static _writeString(String key, String value) async {
    if (isUseGetStorage) {
      return await get_storage.GetStorage().write(key, value);
    }
    return await storage.write(key: key, value: value);
  }

  static Future<String?> _readString(String key) async {
    if (isUseGetStorage) {
      return get_storage.GetStorage().read(key);
    }
    return await GetStorage.storage.read(key: key);
  }

  writeString(String key, String value) async {
    return await _writeString(key, value);
  }

  Future<String?> readString(String key) async {
    return _readString(key);
  }

  writeBool(String key, bool value) async {
    await _writeString(key, value.toString());
  }

  Future<bool?> readBool(String key) async {
    debugPrint('key:$key,value:${await _readString(key)}');
    return await _readString(key) == 'true';
  }

  writeInt(String key, int value) async {
    await _writeString(key, value.toString());
  }

  Future<int?> readInt(String key) async {
    String? value = await _readString(key);
    if (value == null) return null;
    return int.parse(value);
  }

  writeDouble(String key, double value) async {
    await _writeString(key, value.toString());
  }

  Future<double?> readDouble(String key) async {
    String? value = await _readString(key);
    if (value == null) return null;
    return double.parse(value);
  }

  Future<void> remove(String key) async {
    if (isUseGetStorage) {
      await get_storage.GetStorage().remove(key);
    } else {
      await GetStorage.storage.delete(key: key);
    }
  }

  Future<Map<String, dynamic>> readAllKey() async {
    if (isUseGetStorage) {
      List<String> keys = await get_storage.GetStorage().getKeys().toList();
      Map<String, dynamic> map = {};
      for (String element in keys) {
        map[element] = '_';
      }
      return map;
    }
    return await GetStorage.storage.readAll();
  }
}

class IconUtil {
  static const IconData wuXiang =
      IconData(0xe64b, fontFamily: 'StarFamily' // IconFont是pubspec.yaml的命名
          );

  static const IconData empty = IconData(0xe641, fontFamily: 'StarFamily');

  /// 节拍器
  static const IconData metronome = IconData(0xe601, fontFamily: 'StarFamily');

  // 智能助手
  static const IconData assistant = IconData(0xe600, fontFamily: 'StarFamily');

  // 深层思考
  static const IconData deepThink = IconData(0xe850, fontFamily: 'StarFamily');
}

class RouterUtils {
  static void toPlayer(
    String id,
    int shiJiId, {
    ShijiTypeEnum shijiTypeEnum = ShijiTypeEnum.shiji,
    void Function(String path)? toPathCallback,
  }) {
    String path = '${AppRoutes.playnew}/$id/$shiJiId/${shijiTypeEnum.type}';

    if (toPathCallback != null) {
      toPathCallback(path);
      return;
    }
    Get.toNamed(path);
  }

  static void toSongListDetail(int id) {
    Get.toNamed('${AppRoutes.gedanlist}/$id');
  }
}

class Throttler {
  final int millisecounds;
  Timer? _timer;
  bool isExecuted = false;
  Throttler({required this.millisecounds});
  void run(VoidCallback action) {
    if (isExecuted) return;
    _timer = Timer(Duration(milliseconds: millisecounds), () {
      isExecuted = false;
    });
    isExecuted = true;
    action();
  }

  void dispose() {
    _timer?.cancel();
  }
}
