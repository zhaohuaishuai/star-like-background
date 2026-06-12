
import 'package:Shine_like_a_star/container/sgbContainer.dart';
import 'package:Shine_like_a_star/page/BiblePage.dart';
import 'package:Shine_like_a_star/page/FirstPage.dart';
import 'package:Shine_like_a_star/page/SgbAppPage.dart';
import 'package:Shine_like_a_star/page/TichTextPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './page/new_index.dart';
import "package:just_audio_background/just_audio_background.dart";
import 'package:get_storage/get_storage.dart';
import './page/song_list_page.dart';
import './page/shijiTypeList.dart';
import './page/shiji_page.dart';
import './type/sgbType.dart';
import './page/search_page.dart';
import './page/version_page.dart';
import './page/gedan_edit.dart';
import './page/GePu.dart';
import './page/GeCi.dart';
import './utils/utils.dart';
import './page/share_player_page.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'page/TouYing/TPController.dart';
import './container/Tune.dart';
import 'page/GuitarTuning.dart';
import './container/First.dart';
import 'page/MyGeDan.dart';
import './container/GeDan.dart';
import 'page/MyGeDanDetail.dart';
import 'page/OriginalPoetry/index.dart';

import 'page/OriginalPoetry/detail.dart';

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await GetStorage.init();
  Get.put(SgbContainer());
  // Get.put(SgbApp());
  //设置一个设备的id
  var userId = await Jutils.deviceDetails();
  print("userId-->$userId");
  await MatomoTracker.instance.initialize(
      siteId: 6,
      url: 'https://cloud.top237.top/matomo.php',
      visitorId: userId);

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '发光如星',
      debugShowCheckedModeBanner: false,
      // initialRoute: RouteName.GuitarTuning.value,
      initialRoute: RouteName.firstPage.value,
      // color: Colors.indigoAccent,
      theme: ThemeData(
        primaryColor: Colors.deepPurple[800],
        backgroundColor: Colors.deepPurple[400],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[400],
        ),

      ),
      navigatorObservers: [MyObserver()],
      getPages: [

        GetPage(
          title: "富文本页",
          name: RouteName.TichTextPage.value,
          page: () => TichTextPage(),
          binding: FirstBinding(),
        ),
        GetPage(
          title: "调音器",
          name: RouteName.GuitarTuning.value,
          page: () => GuitarTuning(),
          binding: TuneBinding(),
        ),
        GetPage(
          title: "投屏端",
          name: RouteName.TPController.value,
          page: () => TPController(),
        ),
        GetPage(
          title: "发光如星",
          name: RouteName.firstPage.value,
          page: () => FirstPage(),
          binding: FirstBinding(),
          // page: () => NewIndexPage(),
        ),
        GetPage(
          title: "发光如星",
          name: RouteName.SgbList.value,
          page: () => NewIndexPage(),

        ),
        GetPage(
            title: "发光如星—播放器",
            name: RouteName.playerPage.value,
            page: () => SharePlayer(),
            transition: Transition.downToUp),
        GetPage(
            title: "发光如星—播放器",
            name: RouteName.SharePlayerPlage.value,
            page: () => SharePlayer()),
        GetPage(
            title: "播放列表",
            name: RouteName.playerTypeList.value,
            page: () => ShiJiTypeList(),
            transition: Transition.leftToRight,
            middlewares: [Middleware('播放列表')]),
        GetPage(
            title: '歌单列表',
            name: RouteName.SongListPage.value,
            page: () => SongListPage(),
            middlewares: [Middleware('歌单列表')]),
        GetPage(
            name: RouteName.shijiPage.value,
            page: () => ShiJiPage(),
            middlewares: [Middleware('诗集列表')]),
        GetPage(
            title: '搜索页',
            name: RouteName.SearchPage.value,
            page: () => SearchPagePage(),
            middlewares: [Middleware('搜索页')]),
        GetPage(
            title: '通知',
            name: RouteName.VersionPage.value,
            page: () => VersionPage(),
            middlewares: [Middleware('通知')]),
        GetPage(
            title: '歌单编辑',
            name: RouteName.GeDanEditPage.value,
            page: () => GeDanEdit(),
            transition: Transition.downToUp,
            middlewares: [Middleware('歌单编辑')]),
        GetPage(
            name: RouteName.GePuPage.value,
            page: () => GePu(),
            transition: Transition.downToUp,
            middlewares: []),
        GetPage(
            name: RouteName.GeCiPage.value,
            page: () => GeCi(),
            transition: Transition.downToUp,
            middlewares: []),
        GetPage(
            title: "发光如星-诗歌本",
            name: RouteName.SgbAppPage.value,
            page: () => SgbAppPage(),
            transition: Transition.rightToLeft
           ),
        GetPage(
            title: "发光如星-我的歌单",
            name: RouteName.MyGeDan.value,
            page: () => MyGeDan(),
            transition: Transition.rightToLeft,
            binding: GeDanBinding()
        ),
        GetPage(
            title: "发光如星-歌单详情",
            name: RouteName.MyGeDanDetail.value,
            page: () => MyGeDanDetail(),
            transition: Transition.rightToLeft,
            binding: GeDanBinding()
        ),
        GetPage(
            title: "发光如星-经文查询",
            name: RouteName.BiblePage.value,
            page: () => BiblePage(),
            transition: Transition.rightToLeft,

        ),
        GetPage(
          title: "发光如星-原创赞美",
          name: RouteName.OriginalPoetryPage.value,
          page: () => SgbAppPage(),
          transition: Transition.rightToLeft
        )
        // ,
        // GetPage(
        //   title: "发光如星-原创赞美",
        //   name: RouteName.OriginalPoetryDetail.value,
        //   page: () => OriginalPoetryDetail(),
        //   transition: Transition.rightToLeft
        // )
      ],
    );
  }
}

// 导航监听
class MyObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == RouteName.playerPage.value) {
      Jutils.setWebTitle('播放页面');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    if (route.settings.name == RouteName.playerPage.value) {
      Jutils.setWebTitle('发光如星');
    }
  }
}

// 中间件
class Middleware extends GetMiddleware {
  final String title;
  Middleware(this.title) : super();
  @override
  GetPage? onPageCalled(GetPage? page) {
    print("onPageCalled...");
    Jutils.setWebTitle(title);

    return super.onPageCalled(page);
  }

  @override
  void onPageDispose() {
    print("onPageDispose...");

    super.onPageDispose();
    Jutils.setWebTitle('发光如星');
  }
}
