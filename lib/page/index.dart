import 'package:Shine_like_a_star/type/appVersion.dart';
import 'package:Shine_like_a_star/widget/imgage_loading.dart';
import 'package:Shine_like_a_star/widget/title_header.dart';
import "package:flutter/material.dart";
import '../widget/loading.dart';
import '../config/color.dart';
import 'package:get/get.dart';
import '../container/sgbContainer.dart';
import 'package:just_audio/just_audio.dart';
import '../widget/search.dart';
import '../type/sgbType.dart';
import 'package:badges/badges.dart' as badges;
import '../widget/item_more_btn.dart';
import '../utils/utils.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:Shine_like_a_star/utils/downUtils.dart'
    if (dart.library.html) 'package:Shine_like_a_star/utils/downHtmlUtils.dart';

import '../widget/PubScaffold.dart';
class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IndexPage();
  }
}

class _IndexPage extends State<IndexPage>
    with SingleTickerProviderStateMixin, TraceableClientMixin {
  ScrollController scrollController = ScrollController();
  final AudioPlayer player = Get.find<SgbContainer>().player.value;
  final sgbContainer = Get.find<SgbContainer>();
  late AnimationController animationController;
  double roate = 0.0;
  @override
  String get traceName => '首页';

  @override
  String get traceTitle => '进入首页';
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              // color: Colors.blueAccent
              ),
          child: Builder(builder: (context) {
            return InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: MuLuBtn(
                    roate: roate, animationController: animationController));
          }),
        ),
        onDrawerChanged: (bool value) {
          setState(() {
            if (value) {
              roate = 0.8;
            } else {
              roate = 0.0;
            }
          });
        },
        drawer: Drawer(
            backgroundColor: AppColor.appBackgroundColor,
            child: IndexDrawer(
                sgbContainer: sgbContainer,
                scrollController: scrollController)),
        body: Container(
          decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(RouteName.SearchPage.value);
                      },
                      child: SearchBarWidget(
                        autofocus: false,
                      ),
                    )),
                Container(
                  height: 60,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //排序
                        // InkWell(
                        //   onTap: () {
                        //     // 的web端使用监听无效，为了适配web端所以只有这个来做了。
                        //     // 记忆上一次的排序
                        //     sgbContainer.preSorted.value = sgbContainer.sorted.value;
                        //     // 设置当前的排序
                        //     sgbContainer.sorted.value =
                        //         !sgbContainer.sorted.value;
                        //     // 更新大列表
                        //     sgbContainer
                        //         .sortPlayList(sgbContainer.sorted.value);
                        //   },
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Icon(
                        //         Icons.sort_outlined,
                        //         color: Colors.white,
                        //         size: 20,
                        //       ),
                        //       SizedBox(
                        //         width: 4,
                        //       ),
                        //       Obx(() => Text(
                        //             !sgbContainer.sorted.value
                        //                 ? "倒序排序"
                        //                 : "正序排序",
                        //             style: TextStyle(color: Colors.white),
                        //           ))
                        //     ],
                        //   ),
                        // ),
                        SizedBox(
                          width: 20,
                        ),
                        // 消息通知
                        InkWell(
                          onTap: () {
                            Get.toNamed(RouteName.VersionPage.value)!.then((_) {
                              sgbContainer.versionShowDialog.value = false;
                            });
                          },
                          child: Row(
                            children: [
                              Text("通知", style: TextStyle(color: Colors.white)),
                              Obx(() => badges.Badge(
                                  showBadge:
                                      sgbContainer.versionShowDialog.value,
                                  position: badges.BadgePosition(start: 16, top: -10),
                                  borderRadius: BorderRadius.circular(10.0),
                                  shape: badges.BadgeShape.square,
                                  badgeContent: Text(
                                    "新消息",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9),
                                  ),
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 20,
                                  ))),
                            ],
                          ),
                        ),
                        // degub
                        InkWell(
                          onTap: () {
                            Jutils.setWebDebug();
                          },
                          child: Container(width: 30, height: 30),
                        ),


                        // InkWell(
                        //   onTap: (){
                        //     Get.toNamed(RouteName.TPController.value);
                        //   },
                        //   child: Text("投屏",style:TextStyle(color: Colors.white)),
                        // ),
                        SizedBox(width: 10,),
                        //App版本
                        AppVersionBtn(sgbContainer: sgbContainer),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: IndexPlayList(
                    sgbContainer: sgbContainer,
                    player: player,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class AppVersionBtn extends StatefulWidget {
  final SgbContainer sgbContainer;
  AppVersionBtn({
    Key? key,
    required this.sgbContainer,
  }) : super(key: key);

  @override
  _AppVersionBtnState createState() {
    return _AppVersionBtnState();
  }
}

class _AppVersionBtnState extends State<AppVersionBtn> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppVersion?>(
        future: widget.sgbContainer.api.getAppVersion(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              if (PlatformUtils.isWeb) {
                return InkWell(
                  onTap: () {
                    print("ISIOS--${Jutils.isWebIOS()}");
                    if (Jutils.isWebIOS()) {
                      Get.snackbar('提示', 'App暂时不支持苹果IOS系统',
                          backgroundColor: Colors.white);
                      return;
                    }
                    downFile.down('发光如星_${snapshot.data!.version}',
                        snapshot.data!.downpath as String);
                  },
                  child: Text("下载App", style: TextStyle(color: Colors.white)),
                );
              } else {
                return InkWell(
                  onTap: () {
                    print("点击下载：${snapshot.hasData}");
                    if (snapshot.data != null) {
                      Get.dialog(DownAppDialog(data: snapshot.data));
                    }
                  },
                  child:
                  Container(
                    width: 100,
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: Colors.white24,borderRadius: BorderRadius.horizontal(left: Radius.circular(20))),
                    child: Row(children: [
                      Text(
                        '更新App',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CustomFadeTransition(
                          child: Icon(
                            Icons.download,
                            color: Colors.white,
                          )),
                    ]),
                  ),


                );
              }
            }

            return Text("");
          }

          return Text("");
        }));
  }
}

class CustomFadeTransition extends StatefulWidget {
  final Widget child;
  const CustomFadeTransition({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _CustomFadeTransition createState() {
    return _CustomFadeTransition();
  }
}

class _CustomFadeTransition extends State<CustomFadeTransition>
    with TickerProviderStateMixin {
  late AnimationController animatedContainer;
  @override
  void initState() {
    super.initState();
    animatedContainer =
        AnimationController(duration: Duration(milliseconds: 1000), vsync: this)
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    animatedContainer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animatedContainer,
      child: widget.child,
    );
  }
}

class IndexDrawer extends StatelessWidget {
  const IndexDrawer({
    Key? key,
    required this.sgbContainer,
    required this.scrollController,
  }) : super(key: key);

  final SgbContainer sgbContainer;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
      child: ListView(
        children: [
          TitleHeader(
            title: '赞美诗集',
            icon: Icons.ac_unit,
          ),
          ...sgbContainer.sgbdb.value.map((item) {
            return Obx(() => ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(Icons.all_inclusive,color: Colors.white,))),
                ),
                  title: Text(
                    item.name as String,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    sgbContainer.activeIndex == item.id ? '当前在看' : '',
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  onTap: () {
                    Get.back();
                    // Scaffold.of(context).closeDrawer();
                    sgbContainer.updateActiveIndex(item.id);
                    scrollController.jumpTo(0);
                  },
                ));
          }).toList(),
          // FutureBuilder(
          //     future: sgbContainer.api.getSongList('推荐歌单'),
          //     builder: (context, AsyncSnapshot snapshot) {
          //       if (snapshot.connectionState == ConnectionState.done) {
          //         if (snapshot.hasData) {
          //           if (snapshot.data.body == null) {
          //             return Container();
          //           }
          //           var body = SongListBody.fromJson(snapshot.data!.body);
          //           var data = body.data;
          //           List<Widget> wList = [];
          //           List<Widget> gedanList = data!.map((item) {
          //             return ListTile(
          //               leading: ClipRRect(
          //                   borderRadius: BorderRadius.circular(30),
          //                   child: ImageLoading(
          //                     imagePath: item.coverImg ?? AppColor.defaultImag,
          //                   )),
          //               title: Text(
          //                 item.title ?? '',
          //                 style: TextStyle(color: Colors.white),
          //               ),
          //               subtitle: Text(
          //                 item.content ?? '',
          //                 style: TextStyle(color: Colors.white70, fontSize: 12),
          //               ),
          //               onTap: () {
          //                 var ids = item.ids;
          //                 if (ids != '') {
          //                   Get.toNamed(RouteName.SongListPage.value,
          //                       parameters: {
          //                         "ids": item.ids.toString(),
          //                         "title": item.title.toString(),
          //                         "coverImg":
          //                             item.coverImg ?? AppColor.defaultImag
          //                       });
          //                 } else {
          //                   Get.snackbar('提示', "当前歌单没有相应曲目",
          //                       duration: Duration(milliseconds: 700),
          //                       backgroundColor: Colors.white,
          //                       icon: Icon(Icons.sms_failed,
          //                           color: Colors.yellow));
          //                 }
          //               },
          //             );
          //           }).toList();
          //           wList.addAll([
          //             TitleHeader(title: "推荐歌单", icon: Icons.account_balance)
          //           ]);
          //           wList.addAll(
          //             gedanList,
          //           );
          //           if (wList.length == 1) {
          //             return Container();
          //           }
          //           return Column(
          //             children: wList,
          //           );
          //         }
          //         if (snapshot.hasError) {
          //           return Center(
          //             child: Text(
          //               "网络发生错误",
          //               style: TextStyle(color: Colors.white),
          //             ),
          //           );
          //         }
          //       }
          //       return Loading();
          //     }),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}

class IndexPlayList extends StatelessWidget {
  IndexPlayList(
      {Key? key,
      required this.sgbContainer,
      required this.player,
      required this.scrollController})
      : super(key: key);
  final SgbContainer sgbContainer;
  final AudioPlayer player;
  final ScrollController scrollController;
  bool isCurPlayList = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (sgbContainer.initLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      } else {
        return ListView.builder(
            controller: scrollController,
            itemCount: sgbContainer.currendList.value.length,
            itemBuilder: (_, index) {
              var item = sgbContainer.currendList.value[index];
              return ListTile(
                title: Text(
                  item.title,
                  style: TextStyle(color: Colors.white),
                ),
                leading: Text(
                  item.xuhao.toString(),
                  style: TextStyle(color: Colors.white70),
                ),
                subtitle: StreamBuilder(
                  stream: player.currentIndexStream,
                  builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {

                    var iId = item.id.toString();
                    if(player.sequenceState !=null && player.sequenceState!.currentSource != null){
                      var cId = player.sequenceState!.currentSource!.tag!.id.toString();
                      return Text(
                        iId == cId ? "正在播放" : '',
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    return Text('');

                  },
                ),
                onTap: () async {
                  isCurPlayList =
                      await sgbContainer.toPlayPage(item, index, isCurPlayList);
                },
                trailing: Container(
                  width: 50,
                  height: 50,
                  child: ItemMoreBtn(
                    sgbData: item,
                  ),
                ),
              );
            });
      }
    });
  }
}

class MuLuBtn extends StatelessWidget {
  const MuLuBtn({
    Key? key,
    required this.roate,
    required this.animationController,
  }) : super(key: key);
  final double roate;
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TweenAnimationBuilder(
              builder: (BuildContext context, value, Widget? child) {
                return Transform.rotate(
                    angle: value.toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 1.5,
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(2, 2))
                          ]),
                      child: Icon(Icons.add, size: 30, color: Colors.white),
                    ));
              },
              tween: Tween(begin: 0.0, end: roate)
                ..animate(animationController)
                ..chain(CurveTween(curve: Curves.bounceOut)),
              duration: Duration(milliseconds: 600)),
          Padding(padding: EdgeInsets.all(2)),
          Expanded(
            child: Text(
              "诗集",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class DownAppDialog extends StatefulWidget {
  final AppVersion? data;
  DownAppDialog({Key? key, this.data}) : super(key: key);
  @override
  _DownAppDialogState createState() {
    return _DownAppDialogState();
  }
}

class _DownAppDialogState extends State<DownAppDialog> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 320,
          height: 500,
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _progress > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey,
                          semanticsValue: '0.1',
                          semanticsLabel: '下载进度',
                        ),
                      )
                    : Text(''),
                _progress > 0
                    ? Text("下载进度${(_progress * 100).toInt()}%")
                    : Text(""),
                Text(widget.data == null
                    ? ''
                    : "版本号：${widget.data!.version as String}"),
                SizedBox(
                    height: 250,
                    child: Image.asset('assets/images/update.png')),
                Expanded(
                    child: ListView(children: [
                  Text(
                    widget.data == null ? '' : widget.data!.context as String,
                    textAlign: TextAlign.center,
                  )
                ])),
                _progress > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text("下载过程中，请不要退出这个弹窗哦，如果退出了，请重新下载",
                            style: TextStyle(color: Colors.redAccent)),
                      )
                    : ElevatedButton(
                        autofocus: true,
                        onPressed: () {
                          if (_progress == 0) {
                            downFile.down('发光如星_${widget.data!.version}.apk',
                                widget.data!.downpath as String, (progress) {
                              setState(() {
                                _progress = (progress) / 100;
                              });
                            });
                          }
                        },
                        child: Text(
                          "下载并安装",
                        ))
              ]),
        ),
      ),
    );
  }
}
