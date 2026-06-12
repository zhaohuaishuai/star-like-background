import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/services/user.dart';
import 'package:m/features/pages/gedanlist/index.dart';
import 'package:m/features/pages/my/controller.dart';
import 'package:m/shared/widgets/down_pull_refresh.dart';

// ignore: must_be_immutable
class MyPage extends GetWidget<MyController> {
  void Function(int index)? changeTab;
  MyPage({super.key, this.changeTab});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('我的'.tr),
          actions: [
            Obx(() {
              if (UserService.to.isLogin) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    UserService.to.logout();
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.login),
                onPressed: () {
                  UserService.to.showLoginDialog();
                },
              );
            }),
          ],
        ),
        body: Obx(() {
          return Column(
            children: [
              // 同步横幅：登录后且存在未同步的指纹歌单
              _buildSyncBanner(),
              // 用户信息区域
              _buildUserInfoSection(),
              // Tab 切换
              TabBar(
                tabs: [
                  Tab(text: '我的歌单'.tr),
                  Tab(text: '我的收藏'.tr),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMySongList(),
                    _buildMyShouCang(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom:
                        kBottomNavigationBarHeight + StarThemeData.spacing),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    if (UserService.to.isLogin) {
      return Padding(
        padding: EdgeInsets.only(
            left: StarThemeData.spacing,
            right: StarThemeData.spacing,
            bottom: StarThemeData.spacing),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                padding: EdgeInsets.all(StarThemeData.spacing),
                color: StarThemeData.primaryColor.withOpacity(0.2),
                child: Icon(Icons.person_sharp,
                    size: 32, color: StarThemeData.primaryColor),
              ),
            ),
            SizedBox(
              width: StarThemeData.spacing,
            ),
            Text(
              UserService.to.user!.email!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(StarThemeData.spacing),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              padding: EdgeInsets.all(StarThemeData.spacing),
              color: StarThemeData.primaryColor.withOpacity(0.2),
              child: Icon(Icons.person_sharp,
                  size: 32, color: StarThemeData.primaryColor),
            ),
          ),
          SizedBox(width: StarThemeData.spacing),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('欢迎来到发光如星', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('登录后可同步歌单到账号',
                  style: TextStyle(
                      fontSize: 12,
                      color: StarThemeData.primaryColor.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }

  /// 同步横幅：登录后且存在未同步的指纹歌单时显示
  Widget _buildSyncBanner() {
    return Obx(() {
      if (!UserService.to.isLogin) return const SizedBox();
      // 检查是否有 userId 为 null 的歌单（指纹歌单）
      bool hasFpSongList = UserService.to.songList
          .any((song) => song.userId == null && song.fingerprintId != null);
      if (!hasFpSongList) return const SizedBox();

      return Container(
        margin: EdgeInsets.symmetric(
            horizontal: StarThemeData.spacing, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: StarThemeData.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.sync, color: StarThemeData.primaryColor, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('同步歌单到账号',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                  Text('将设备歌单合并到登录账号',
                      style: TextStyle(
                          fontSize: 11,
                          color: StarThemeData.primaryColor
                              .withOpacity(0.6))),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await UserService.to.syncFingerprintSongList();
              },
              child: Text('同步'),
            ),
          ],
        ),
      );
    });
  }

  _buildMyShouCang() {
     return DownPullRefresn(
      onRefresh: () async {
        await UserService.to.getShouCang();
      },
      child: SongListDetailIist(controller: controller)
      );
  }

  _buildMySongList() {
    return Obx(() {
      if (UserService.to.songList.isNotEmpty) {
        return DownPullRefresn(
          onRefresh: () async {
            await UserService.to.getSongList();
          },
          child: Column(
            children: [
              Row(
                children: [
                  if (!UserService.to.isLogin)
                    Padding(
                      padding: EdgeInsets.only(left: StarThemeData.spacing),
                      child: Text('指纹设备歌单',
                          style: TextStyle(
                              fontSize: 11,
                              color: StarThemeData.primaryColor)),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    label: Text('创建歌单'.tr),
                    onPressed: () {
                      UserService.to.addSongList();
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: UserService.to.songList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        RouterUtils.toSongListDetail(
                            UserService.to.songList[index].id);
                      },
                      title: Text(UserService.to.songList[index].name),
                      subtitle:
                          Text('${UserService.to.songList[index].createTime}'),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 18),
                                  SizedBox(
                                    width: StarThemeData.spacing,
                                  ),
                                  Text('删除'.tr),
                                ],
                              ),
                              onTap: () {
                                UserService.to.delSongList(
                                    UserService.to.songList[index].id);
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 18),
                                  SizedBox(
                                    width: StarThemeData.spacing,
                                  ),
                                  Text('重命名'.tr)
                                ],
                              ),
                              onTap: () {
                                UserService.to.addSongList(
                                    UserService.to.songList[index].id,
                                    UserService.to.songList[index].name);
                              },
                            ),
                          ];
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          IconUtil.empty,
          size: 120,
          color: StarThemeData.primaryColor.withOpacity(0.5),
        ),
        SizedBox(
          height: StarThemeData.spacing,
        ),
        TextButton.icon(
          onPressed: () {
            UserService.to.addSongList();
          },
          label: Text('创建歌单'.tr),
          icon: const Icon(Icons.add),
        )
      ]);
    });
  }
}
