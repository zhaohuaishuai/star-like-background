import 'package:Shine_like_a_star/type/sgbType.dart';
import 'package:flutter/material.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import '../widget/loading.dart';
import '../widget/shiji_box.dart';
import '../widget/title_header.dart';
import '../widget/gedan_box.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> with TraceableClientMixin {
  final sgbContainer = Get.find<SgbContainer>();
  var versionDialog = null;
  var _getSongList;

  @override
  String get traceName => '首页';

  @override
  String get traceTitle => '首页';

  @override
  void initState() {
    super.initState();
    _getSongList = Get.find<SgbContainer>().api.getSongList('推荐歌单');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // showDialog(context: context, builder: builder)

    // TODO: implement build
    return SafeArea(
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: ListView(
              children: [
                Column(
                  children: [
                    Obx(() {
                      if (sgbContainer.versionShowDialog.value) {
                        Future.delayed(Duration(milliseconds: 1000), () {
                          print("延时1秒执行");
                          if (versionDialog == null) {
                            Get.defaultDialog(
                                title: "版本更新",
                                content: Html(
                                    data: sgbContainer.versionContext.value),
                                textCancel: "取消",
                                textConfirm: "确认",
                                barrierDismissible: false,
                                onCancel: () {
                                  sgbContainer.versionShowDialog.value = false;
                                },
                                onConfirm: () {
                                  sgbContainer.versionShowDialog.value = false;
                                });
                            versionDialog = 1;
                          }
                        });
                      }
                      return Container();
                    }),
                    SizedBox(
                      height: 30,
                    ),
                    //搜索框
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(RouteName.SearchPage.value);
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Positioned(
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: Image.asset(
                                    'assets/images/seacher_icon.png',
                                  ),
                                ),
                                top: 7,
                                left: 10,
                              ),
                              Positioned(
                                child: SizedBox(
                                  width: 106,
                                  height: 26,
                                  child: Text("搜索歌曲",
                                      style: TextStyle(
                                        color: Color.fromARGB(155, 0, 22, 84),
                                        fontSize: 16,
                                      )),
                                ),
                                top: 6,
                                left: 39,
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromARGB(120, 166, 166, 166),
                                    offset: Offset(5.0, 5.0),
                                    blurRadius: 6.0),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TitleHeader(
                      title: "赞美诗集",
                      icon: Icons.music_note,
                      onPressed: () {
                        Get.toNamed(RouteName.shijiPage.value);
                      },
                    ),
                    // 诗集
                    Obx(() {
                      if (sgbContainer.sgbdb.value.length == 0) {
                        return Loading();
                      }
                      var list = sgbContainer.sgbdb.value
                          .getRange(0, 3)
                          .toList()
                          .map((item) {
                        return ShiJiBox(
                            imagePath: item.thumbnails ?? '',
                            title: item.name ?? '',
                            id: item.id as int);
                      }).toList();
                      return Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: list,
                          ));
                    }),
                    // 推荐歌单
                    Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: FutureBuilder(
                          future: _getSongList,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                var body =
                                    SongListBody.fromJson(snapshot.data!.body);
                                var data = body.data;
                                List<Widget> wList = [];
                                List<Widget> gedanList = data!.map((item) {
                                  return GeDanBox(
                                    title: item.title as String,
                                    coverImg: item.coverImg,
                                    content: item.content ?? '暂无内容',
                                    id: item.id ?? '',
                                    ids: item.ids ?? '',
                                  );
                                }).toList();
                                wList.addAll([
                                  TitleHeader(
                                      title: "推荐歌单", icon: Icons.app_blocking)
                                ]);
                                wList.addAll(
                                  gedanList,
                                );
                                return Column(
                                  children: wList,
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "网络发生错误",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                            }
                            return Loading();
                          }),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
