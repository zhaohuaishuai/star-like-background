import 'package:get/get.dart';
import 'package:m/features/pages/bible/index.dart';
import 'package:m/features/pages/feedback/index.dart';
import 'package:m/features/pages/gedanlist/buinding.dart';
import 'package:m/features/pages/gedanlist/index.dart';
import 'package:m/features/pages/home/binding.dart';

import 'package:m/features/pages/index/index.dart';
import 'package:m/features/pages/my/buding.dart';

import 'package:m/features/pages/playnew/binding.dart';
import 'package:m/features/pages/playnew/index.dart';
import 'package:m/features/pages/screen_casting/index.dart';
import 'package:m/features/pages/search/binding.dart';
import 'package:m/features/pages/search/index.dart';
import 'package:m/features/pages/settings/binding.dart';
import 'package:m/features/pages/settings/index.dart';
import 'package:m/features/pages/sgb/binding.dart';
import 'package:m/features/pages/webview/buinding.dart';
import 'package:m/features/pages/webview/index.dart';
import 'package:m/features/pages/file_store/index.dart';
import 'package:m/features/pages/file_store/binding.dart';

// /gedanlist/18588
class AppRoutes {
  static const String index = '/';
  static const String home = '/home';
  static const String my = '/my';
  static const String login = '/login';
  static const String register = '/register';
  static const String search = '/seachersgb';
  static const String playnew = '/playnew';
  static const String gedanlist = '/gedanlist';
  static const String webview = '/webview';
  static const String screenCating = '/t';
  static const String jingwengres = '/jingwengres';
  static const String settings = '/settings';
  static const String fileStore = '/file_store';
  static List<GetPage> pages = [
    GetPage(
        name: index,
        page: () => const IndexPage(),
        binding: HomeBinding(),
        bindings: [
          HomeBinding(),
          MyBinding(),
          SgbBinding(),
        ]),
    GetPage(
        name: search, page: () => const SearchPage(), binding: SearchBinding()),
    GetPage(
        name: '/settings',
        page: () => const SettingsPage(),
        binding: SettingsBinding()),
    GetPage(
        name: '/playnew/:id/:gedanid/:type',
        page: () => const PlayNewPage(),
        binding: PlayNewBinding(),
        transition: Transition.downToUp),
    GetPage(
        name: '/playnew',
        page: () => const PlayNewPage(),
        binding: PlayNewBinding(),
        transition: Transition.downToUp),
    GetPage(
        name: '$gedanlist/:id',
        page: () => const GeDanListPage(),
        binding: GeDanListBinding()),
    GetPage(
        name: gedanlist,
        page: () => const GeDanListPage(),
        binding: GeDanListBinding()),
    GetPage(
        name: '$webview/:id',
        page: () => const WebViewPage(),
        binding: WebViewBinding()),
    GetPage(
        name: webview,
        page: () => const WebViewPage(),
        binding: WebViewBinding()),
    GetPage(name: screenCating, page: () => const ScreenCatingPage()),
    GetPage(name: jingwengres, page: () => const BiblePage()),
    GetPage(
        name: fileStore,
        page: () => const FileStorePage(),
        binding: FileStoreBinding()),
    GetPage(
        name: '/feedback',
        page: () => FeedbackPage()),
  ];
} 


// export const routes = [
//   {
//     path: "/",
//     name: "layout-index",
//     component: Layout,
//     redirect: "/home",
//     meta: {
//       title: `${title}首页`,
//       keepAlive: true,
//     },
//     children: [
//       {
//         path: "/home",
//         name: "star-home",
//         component: () => import("@/views/HomeNew.vue"),
//         // redirect:'/home', // flower home
//         meta: {
//           title: `${title}首页`,
//           share: true,
//           keepAlive: true,
//         },
//       },
//       {
//         path: "/me",
//         name: "Me",
//         component: () => import("@/views/Me"),
//         meta: {
//           title: `${title}-我的`,
//           keepAlive: true,
//           login: true,
//         },
//       },
//       {
//         path: "/sgb",
//         name: "sgb-index",
//         component: () => import("@/views/Sgb/SgbIndex.vue"),
//         meta: {
//           title: `${title}诗歌本`,
//           share: true,
//           keepAlive: true,
//         },
//       },
//       {
//         path: "/playnew/:id/:gedanid/:type",
//         name: PLAYNEWPAGENAME,
//         component: () => import("@/views/PlayNew/index.vue"),
//         meta: {
//           title: `${title}播放页面`,
//           share: true,
//           keepAlive: false,
//         },
//         props: true,
//       },
//       {
//         path: "/share-lyric/:id",
//         name: "share-lyric-page",
//         component: () => import("@/views/ShareLyric/index.vue"),
//         meta: { title: "歌词分享", keepAlive: false },
//         props: true,
//       },
//       {
//         path: "/seachersgb",
//         name: "seacherSgb",
//         component: () => import("@/views/SeacherSgb/index.vue"),
//         meta: { title: `${title}搜索`, keepAlive: true },
//         props: true,
//       },
//       {
//         path: "/original_poetry",
//         name: "OriginalPoetry",
//         component: () => import("@/views/OriginalPoetry/index.vue"),
//         meta: {
//           title: `${title}原创诗歌`,
//           share: true,
//           keepAlive: true,
//         },
//       },
//       {
//         path: "/original_poetry_detail/:id",
//         name: "OriginalPoetryDetail",
//         component: () => import("@/views/OriginalPoetry/detail.vue"),
//         meta: {
//           title: `${title}原创诗歌`,
//           share: true,
//           keepAlive: true,
//         },
//         props: true,
//       },
//       {
//         path: "/appdownload",
//         name: "AppDownload",
//         component: () => import("@/views/AppDownload/index.vue"),
//         meta: { title: `${title}APP下载`, keepAlive: true },
//       },
//       {
//         path: "/mygedan",
//         name: "MyGeDan",
//         component: () => import("@/views/MyGeDan/index.vue"),
//         meta: { title: `${title}我的歌单`, share: false, keepAlive: true, login: true },
//       },
//       {
//         path: "/gedanlist/:id",
//         name: "GeDanList",
//         component: () => import("@/views/GeDanDatilList/index.vue"),
//         meta: {
//           title: `${title}歌单列表`,
//           share: false,
//           keepAlive: true,
//         },
//         props: true,
//       },
//       {
//         path: "/t",
//         name: "TouYingNav",
//         component: () => import("@/views/TouYing/Navig.vue"),
//         meta: { title: `${title}投影导航`, share: false, keepAlive: true },
//         props: true,
//       },
//       {
//         path: "/touying/:id?",
//         name: "Touying",
//         component: () => import("@/views/TouYing/TouYingControl.vue"),
//         meta: { title: `${title}投影`, share: false, keepAlive: false },
//         // props: true,
//       },
//       {
//         path: "/register",
//         name: "Register",
//         component: () => import("@/views/Login/index.vue"),
//         meta: { title: "用户注册", keepAlive: false },
//       },
//       {
//         path: "/login",
//         name: "Login",
//         component: () => import("@/views/Login/index.vue"),
//         meta: { title: "用户登录", keepAlive: false },
//       },
//       {
//         path: "/forget_password",
//         name: "Forget",
//         component: () => import("@/views/Login/index.vue"),
//         meta: { title: "忘记密码", keepAlive: false },
//       },
//       {
//         path: "/member_validate_code",
//         name: "MemberValidate",
//         component: () => import("@/views/MemberValidate/index.vue"),
//         meta: {
//           title: "账号验证",
//           keepAlive: false,
//         },
//         props: true,
//       },
//       {
//         path: "/deep_breathe",
//         name: "DeepBreathe",
//         component: () => import("@/views/DeepBreathe/index.vue"),
//         meta: { title: `${title}深呼吸`, keepAlive: false },
//       },
//     ],
//   },
//   {
//     path: "/fangying/:id",
//     name: "FangYing",
//     component: () => import("@/views/TouYing/FangYing.vue"),
//     meta: { title: `${title}投影大屏`, share: false, keepAlive: true },
//     // props: true,
//   },
//   {
//     path: "/jingwengres",
//     name: "JingWengRes",
//     component: () => import("@/views/SeacherSgb/JinWenRes.vue"),
//     meta: { title: `${title}经文`, keepAlive: true },
//     props: true,
//   },
//   {
//     path: "/leafer",
//     name: "Leafer",
//     component: () => import("@/views/Test/tra3d.vue"),
//     meta: { title: `${title}`, keepAlive: false },
//   },
//   {
//     path: "/privacy",
//     name: "Privacy",
//     component: () => import("@/views/Privacyagreement/index.vue"),
//     meta: { title: `隐私协议`, keepAlive: false },
//   },
//   {
//     path: "/supper",
//     name: "SupportPage",
//     component: () => import("@/views/Support/index.vue"),
//     meta: { title: `App支持`, keepAlive: false },
//   },
// ]; 
