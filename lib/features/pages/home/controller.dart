import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/index.dart';
import 'package:m/data/module/app_version.dart';
import 'package:m/data/module/notice.dart';
import 'package:m/data/module/recommend.dart';
import 'package:m/data/module/sgb_data.dart';
import 'package:m/data/services/sgb.dart';
import 'package:m/data/services/star_player.dart';
import 'package:m/shared/widgets/version_update_dialog/index.dart';

class HomeController extends GetxController {
  StarPlayerAbstract starPlayer = StarPlayer.to;
  RxInt counter = 0.obs;
  RxList<Notice> noticeList = <Notice>[].obs;
  final RxList<Recommend> _recommendList = <Recommend>[].obs;

  GlobalKey sgbHeaderTabKey = GlobalKey();
  final box = GetStorage();
  // ignore: invalid_use_of_protected_member
  List<Recommend> get recommendList => _recommendList;

  RxInt currentIndex = 0.obs;
  /// 轮播图当前活跃索引，用于控制图片懒加载
  RxInt activeBannerIndex = 0.obs;
  /// 已加载过的轮播图图片索引，加载后不再降级为占位图
  final Set<int> _loadedBannerIndices = {};

  /// 检查轮播图图片是否已加载过
  bool isBannerImageLoaded(int index) => _loadedBannerIndices.contains(index);

  /// 标记轮播图图片已加载
  void markBannerImageLoaded(int index) => _loadedBannerIndices.add(index);

  IndexProvider api = Get.put<IndexProvider>(IndexProvider());
  RxBool isLoading = false.obs;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  RxBool get isDesc => SgbService.to.isDesc;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();

    initData();
  }

  void initData() async {
    isLoading.value = true;

    try {
      noticeList.value = await api.getNoticeList();
      _recommendList.value = await api.recommend();
    } catch (e) {
      debugPrint('首页数据获取报错：${e.toString()} ${e.runtimeType}');
    } finally {
      isLoading.value = false;
    }

    onShowVersionDialog();
  }

  @override
  void onClose() {
    super.onClose();

    searchController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
  }

  void toSearch() {
    Get.toNamed(AppRoutes.search);
    searchController.clear();
  }

  void toRecommendLink(String link) {
    if (link.startsWith('/#')) {
      link = link.replaceFirst('/#', '');
    }
    Get.toNamed(link);
  }

  void onRefresh() async {
    await SgbService.to.refresh();
    initData();
  }

  void onSort() {
    SgbService.to.onSort();
  }

  List<SgbData> get currentList {
    return SgbService.to.getSgbDataListByShijiTypeIndex(currentIndex.value);
  }

  List<List<SgbData>> get shijiTypeList => SgbService.to.shijiTypeList
      .map((e) => SgbService.to.getSgbDataListByShijiTypeById(e.id))
      .toList();

  showDetail(SgbData data, int index) {
    debugPrint('showDetail $data $index');
    RouterUtils.toPlayer(data.id, data.shijiIndex);
  }

  void toWebView(int id) {
    Get.toNamed('${AppRoutes.webview}/$id');
  }

  void toNavWebView(String url, String title) {
    // 对 URL 进行编码，以保留 # 后面的路径
    var encodedUrl = Uri.encodeComponent(url);
    var webviewurl = '${AppRoutes.webview}?url=$encodedUrl&title=$title';
    Get.toNamed(webviewurl);
  }

  Future<AppVersion?> getAppVersion() async {
    return await api.getAppVersion();
  }

  onShowVersionDialog() async {
    if (Platform.isAndroid) {
      AppVersion? appVersion = await getAppVersion();
      if (appVersion == null) {
        return;
      }
      String version = await Utils.getAppVersion();
      debugPrint(version);
      debugPrint((version == appVersion.version).toString());
      if (version == appVersion.version) {
        return;
      }
      VersionUpdateDialog.show(appVersion);
    }
  }
}
