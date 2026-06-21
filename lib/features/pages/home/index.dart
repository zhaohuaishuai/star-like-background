import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';

import 'package:m/data/services/sgb.dart';
import 'package:m/data/services/user.dart';
import 'package:m/features/pages/home/controller.dart';
import 'package:m/shared/widgets/down_pull_refresh.dart';
import 'package:m/shared/widgets/empty.dart';
import 'package:m/shared/widgets/loading.dart';
import 'package:m/shared/widgets/setting.dart';
import 'package:m/shared/widgets/shimmer_widget/index.dart';
import 'package:m/shared/builder/sliver_persistent_header_builder.dart';
import 'package:m/shared/widgets/i_18n_select.dart';
import 'package:m/shared/widgets/h1.dart';
import 'package:m/shared/widgets/scroll_tab_bar.dart';
import 'package:m/shared/widgets/search_text_field.dart';
import 'package:m/shared/widgets/song_list_tile.dart';
import 'package:m/shared/widgets/icon_text_widget.dart';
import 'package:m/shared/widgets/theme_switch.dart';

class HomePage extends GetWidget<HomeController> {
  final void Function(int index)? onTabChange;
  const HomePage({
    super.key,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => DownPullRefresn(
            onRefresh: () async {
              return controller.onRefresh();
            },
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                _appBarBuilder(),
                _noticeBuilder(),
                _recommendBuilder(),
                _mySongListBuild(),
                _minAppBuild(),
                // _sgbBuild(context),
                // _sgbListBuild(context),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: StarThemeData.bottomPadding),
                )
              ],
            ),
          )),
    );
  }

  _noticeBuilder() {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(
        child: ShimmerWidget(
          padding: EdgeInsets.symmetric(
              vertical: 8, horizontal: StarThemeData.spacing),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: StarThemeData.spacing,
        ),
        height: 36,
        child: Swiper(
            duration: 500,
            loop: true,
            autoplay: true,
            scrollDirection: Axis.vertical,
            // ignore: invalid_use_of_protected_member
            itemCount: controller.noticeList.value.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () =>
                    controller.toWebView(controller.noticeList[index].id),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: StarThemeData.spacing,
                    right: StarThemeData.spacing,
                  ),
                  child: Text(
                    // ignore: invalid_use_of_protected_member
                    controller.noticeList.value[index].title,
                    style: const TextStyle(color: Color(0XFF6A6A6A)),
                  ),
                ),
              );
            }),
      ),
    );
  }

  _appBarBuilder() {
    return SliverAppBar(
      pinned: true,
      title: SearchTextField(
        readOnly: true,
        onTap: controller.toSearch,
        focusNode: controller.searchFocusNode,
        controller: controller.searchController,
        autofocus: false,
      ),
      centerTitle: false,
      actions: const [
        I18nSelect(),
        ThemeSwitch(),
        SettingWidget(),
        SizedBox(width: 12)
      ],
    );
  }

  _recommendBuilder() {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(
        child: ShimmerWidget(
          padding: EdgeInsets.symmetric(
              vertical: 80, horizontal: StarThemeData.spacing),
          child: Center(
            child: Text('加载中...'.tr,
                style: TextStyle(
                    fontSize: 16, color: StarThemeData.loadingTextColor)),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          H1(
            title: '推荐歌单'.tr,
          ),
          LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxWidth / (16 / 9),
              child: Swiper(
                  autoplay: true,
                  duration: 1000,
                  loop: true,
                  scrollDirection: Axis.horizontal,
                  viewportFraction: 0.9,
                  scale: 1,
                  itemCount: controller.recommendList.length,
                  onIndexChanged: (index) {
                    // 更新当前活跃索引，触发懒加载
                    controller.activeBannerIndex.value = index;
                  },
                  itemBuilder: (context, index) {
                    // 只加载当前活跃和相邻的图片，其余显示占位图
                    final activeIndex = controller.activeBannerIndex.value;
                    final isActive = index == activeIndex;
                    final isNearby = (index - activeIndex).abs() <= 1;
                    return Padding(
                        padding: EdgeInsets.only(
                          left: StarThemeData.spacing,
                          right: StarThemeData.spacing,
                        ),
                        child: InkWell(
                          onTap: () {
                            controller.toRecommendLink(
                                controller.recommendList[index].linkUrl);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                SizedBox(
                                    width: constraints.maxWidth,
                                    height: constraints.maxWidth / (16 / 9),
                                    child: isActive || isNearby
                                        ? Image.network(
                                            fit: BoxFit.cover,
                                            // ignore: invalid_use_of_protected_member
                                            controller
                                                .recommendList[index].imgUrl)
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.white54,
                                                size: 48,
                                              ),
                                            ),
                                          )),
                              ],
                            ),
                          ),
                        ));
                  }),
            );
          }),
        ],
      ),
    );
  }

  _sgbBuild(BuildContext context) {
    double padding = StarThemeData.spacing;
    double height = 96;
    double sgbHeaderTop = 0;
    return SliverPersistentHeader(
      pinned: true,
      delegate: Sliverpersistentheaderbuilder(
        max: height,
        min: height,
        builder: (context, shrinkOffset, overlapsContent) {
          if (overlapsContent) {
            if (sgbHeaderTop == 0) {
              sgbHeaderTop = controller.scrollController.offset;
            }
          }

          Widget tabs = ShimmerWidget(
            padding: EdgeInsets.symmetric(
                horizontal: StarThemeData.spacing, vertical: 6),
            child: Text(
              'Loading...',
              style: TextStyle(color: StarThemeData.loadingTextColor),
            ),
          );

          if ((!SgbService.to.loading.value &&
              SgbService.to.shijiTypeList.isNotEmpty)) {
            tabs = ScrollTabBar(
              keepAlive: true,
              currentIndex: controller.currentIndex.value,
              padding: padding,
              tabs: SgbService.to.shijiTypeList.map((e) => e.name).toList(),
              onChanged: (value) {
                debugPrint('value:$value');
                controller.currentIndex.value = value;
                if (overlapsContent) {
                  controller.scrollController.jumpTo(sgbHeaderTop);
                }
              },
            );
          }
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: controller.sgbHeaderTabKey,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    children: [
                      H1(
                        title: '诗歌本'.tr,
                      ),
                      const Spacer(),
                      sortBuilder(),
                      sgbDetailBtnRender()
                    ],
                  ),
                ),
                tabs,
              ],
            ),
          );
        },
      ),
    );
  }

  Obx sortBuilder() {
    return Obx(() {
      return IconButton(
        icon: Row(
          children: [
            Text(controller.isDesc.value ? '降序'.tr : '升序'.tr),
            RotatedBox(
              quarterTurns: controller.isDesc.value ? 0 : 2,
              child: const Icon(Icons.sort),
            ),
          ],
        ),
        onPressed: () {
          controller.onSort();
        },
      );
    });
  }

  PopupMenuButton<int> sgbDetailBtnRender() {
    return PopupMenuButton(
      icon: const Icon(Icons.menu),
      itemBuilder: (context) {
        return SgbService.to.shijiTypeList
            .map((e) => PopupMenuItem(
                  value: e.id,
                  child: Text(e.name),
                ))
            .toList();
      },
      onSelected: (value) {
        controller.currentIndex.value = SgbService.to.shijiTypeList
            .indexWhere((element) => element.id == value);
      },
    );
  }

  _sgbListBuild(BuildContext context) {
    if (SgbService.to.loading.value || controller.currentList.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: LoadingWidget()),
      );
    }

    if (controller.currentList.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: EmptyWidget(
            size: 80,
            desc: '暂无数据'.tr,
          ),
        ),
      );
    }

    return SliverList.builder(
        itemCount: controller.currentList.length,
        itemBuilder: (context, index) {
          return SongListTile(
            song: controller.currentList[index],
            onTap: (song) =>
                controller.showDetail(controller.currentList[index], index),
          );
        });
  }

// /我的歌单
  _mySongListBuild() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (UserService.to.songList.isNotEmpty) {
          return SizedBox(
            height: 80,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    H1(
                      title: '我的歌单'.tr,
                    ),
                    const Spacer(),
                    TextButton(
                      child: Text('查看更多'.tr),
                      onPressed: () {
                        onTabChange?.call(1);
                        // Get.toNamed(Routes.createSong);
                      },
                    ),
                  ],
                ),
                //  横向滑动的卡片

                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: StarThemeData.spacing),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: StarThemeData.primaryColor.withOpacity(0.2)),
                      child: Swiper(
                        duration: 500,
                        loop: true,
                        autoplay: true,
                        scrollDirection: Axis.vertical,
                        axisDirection: AxisDirection.down,
                        itemCount: UserService.to.songList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              RouterUtils.toSongListDetail(
                                  UserService.to.songList[index].id);
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: StarThemeData.spacing),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    UserService.to.songList[index].name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return Container();
        }
      }),
    );
  }

  _minAppBuild() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          H1(
            title: '小程序'.tr,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconTextWidget(
                icon: IconUtil.deepThink,
                text: '深层呼吸'.tr,
                iconSize: 54,
                onTap: () {
                  controller.toNavWebView(
                      'https://star.top237.top/#/deep_breathe', '深层呼吸'.tr);
                },
              ),
              IconTextWidget(
                icon: IconUtil.assistant,
                text: '智能助手'.tr,
                iconSize: 54,
                onTap: () {
                  controller.toNavWebView(
                      'https://star.top237.top/agent', '智能助手'.tr);
                },
              ),
              IconTextWidget(
                icon: Icons.feedback,
                text: '问题反馈'.tr,
                iconSize: 54,
                onTap: () {
                  Get.toNamed('/feedback');
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
