import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/services/user.dart';
import 'package:m/features/pages/gedanlist/index.dart';
import 'package:m/features/pages/my/controller.dart';
import 'package:m/shared/widgets/button/primary_button.dart';
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
              return Container();

              // return IconButton(
              //   icon: const Icon(Icons.login),
              //   onPressed: () {
              //     UserService.to.showLoginDialog();
              //   },
              // );
            }),
          ],
        ),
        body: Obx(() {
          if (UserService.to.isLogin) {
            return Column(
              children: [
                Padding(
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
                ),
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
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      color: StarThemeData.primaryColor.withOpacity(.2),
                      padding: EdgeInsets.all(StarThemeData.spacing),
                      child: Icon(Icons.person,
                          size: 128, color: StarThemeData.primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: StarThemeData.spacing,
                  ),
                  PrimaryButton(
                      onPressed: () {
                        UserService.to.showLoginDialog();
                      },
                      text: '登录'),
                ],
              ),
            );
          }
        }),
      ),
    );
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
