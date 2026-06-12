import 'package:get/get.dart';

const String appName = '发光如星';
const String baseApi = 'https://api.top237.top/ry-api';
//  本地开发环境的内网穿透链接
// const String baseApi = "http://z694d9dd.natappfree.cc/dev-api";
const String playCoverUrl =
    'https://project-star.oss-cn-beijing.aliyuncs.com/img/calm-sea-on-sunset-with-lighthouse-free-vector.jpg';

const String playDarkCoverUrl =
    'https://oss.top237.top/2025/10/21/68f73952a3c1b.jpg';

// class LocalStorageKey {
//   // 排序字段
//   static const String sort = "_sort";

//   // 播放模式
//   static const String playMode = "_play_mode";
// }

const String shareBaseUrl = 'https://star.top237.top/#';

// 缓存分割符
const String cacheSplit = '___';

const String hobileBookDb =
    'https://oss.top237.top/npm/static/sqllite/20260428093009_bible.db';

const String webViewJsLet = 'Flutter';

enum WebViewMethodEnum {
  back('back');

  final String method;

  const WebViewMethodEnum(this.method);

  @override
  String toString() {
    return method;
  }

  call() {
    if (method == WebViewMethodEnum.back.toString()) {
      Get.back();
      return;
    }
  }
}

const String appDownUrl = 'https://star.top237.top/#/appdownload';
const String sentryDnsUrl =
    'https://1262f35686efc15fad3be558e40dd359@o4509721738018816.ingest.us.sentry.io/4509721744572416';

enum PlayTargetEnum {
  banZou,
  yuanChang,
}
