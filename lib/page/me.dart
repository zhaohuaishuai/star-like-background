import 'package:Shine_like_a_star/widget/imgage_loading.dart';
import 'package:Shine_like_a_star/widget/title_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import '../config/color.dart';
import '../widget/play_list_page.dart';
import '../storage/sgbStorage.dart';
import '../type/sgbType.dart';
import '../page/player_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:matomo_tracker/matomo_tracker.dart';

class Me extends StatefulWidget {
  Me({Key? key}) : super(key: key);

  @override
  _MeState createState() {
    return _MeState();
  }
}

class _MeState extends State<Me> with TraceableClientMixin {
  SgbStorage storage = SgbStorage();
  late SgbContainer sgbContainer;
  final AudioPlayer player = Get.find<SgbContainer>().player.value;
  List<SgbData> historyList = [];
  List<SongListData> songList = [];
  @override
  // TODO: implement traceName
  String get traceName => '我的';

  @override
  // TODO: implement traceTitle
  String get traceTitle => '进入我的';
  @override
  void initState() {
    print("initState");
    sgbContainer = Get.find<SgbContainer>();
    try {
      initdata();
    } catch (err) {
      print("出错了-->$err");
    }

    super.initState();
    _deviceDetails();
  }

  initdata() {
    setState(() {
      historyList = storage.history;
      songList = storage.songList;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String deviceName = '';
  String deviceVersion = '';
  String identifier = '';
  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
          deviceVersion = build.version.toString();
          identifier = build.androidId;
        });
        //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          identifier = data.identifierForVendor;
        }); //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    } catch (err) {
      print("这个是web平台");
    }
  }

  @override
  Widget build(BuildContext context) {
    var isUpdateHistoryList = false;
    // TODO: implement build

    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "播放器",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w800),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TitleHeader(
              title: '自建歌单 ${songList.length}个',
              icon: Icons.list,
              rightBtn: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Get.toNamed(RouteName.GeDanEditPage.value)!.then((value) {
                    initdata();
                  });
                },
              ),
            ),
            Container(
              height: 110,
              clipBehavior: Clip.none,
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...List.generate(songList.length, (index) {
                    var item = songList[index];
                    var coverImg =
                        (item.coverImg == null || item.coverImg == '')
                            ? AppColor.defaultImag
                            : item.coverImg.toString();
                    return InkWell(
                      onTap: () {
                        if (item.ids != '') {
                          Get.toNamed(RouteName.SongListPage.value,
                                  parameters: {
                                "ids": item.ids as String,
                                "title": item.title as String,
                                "coverImg": coverImg
                              })!
                              .then((val) {
                            setState(() {
                              initdata();
                            });
                          });
                        } else {
                          Get.snackbar('提示', "当前歌单没有相应曲目");
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 100,
                            width: 160,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ?? '',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        item.content ?? '',
                                        textAlign: TextAlign.left,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w300),
                                        overflow: TextOverflow.values.last,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ImageLoading(
                                      imagePath: coverImg,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              right: 25,
                              top: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        Map<String, String> params = Map();
                                        params['id'] = item.id.toString();
                                        Get.toNamed(
                                                RouteName.GeDanEditPage.value,
                                                parameters: params)!
                                            .then((value) {
                                          initdata();
                                        });
                                      },
                                      child: Icon(
                                        Icons.edit_calendar_outlined,
                                        size: 16,
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        print("删除");
                                        Get.defaultDialog(
                                            title: "提示",
                                            content: Text("确认删除这个歌单吗？"),
                                            textCancel: "取消",
                                            textConfirm: "确认",
                                            barrierDismissible: false,
                                            onCancel: () {
                                              // sgbContainer.versionShowDialog.value = false;
                                            },
                                            onConfirm: () {
                                              Get.back();
                                              setState(() {
                                                storage.delSongList(
                                                    item.id.toString());
                                                initdata();
                                              });
                                            });
                                      },
                                      child: Icon(
                                        Icons.delete_forever,
                                        size: 16,
                                      )),
                                ],
                              ))
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
            Expanded(
                child: PlayList(
                    listTitle: '最近听过',
                    list: historyList,
                    player: sgbContainer.player.value,
                    onTap: (SgbData data, int index) async {
                      await sgbContainer.songLostToPlayerPage(
                          isUpdateHistoryList, data, index, historyList, () {
                        initdata();
                      });
                      // await songLostToPlayerPage(isUpdateHistoryList, data, index);
                    }))
          ],
        ),
      ),
    ));
  }

  Future<void> songLostToPlayerPage(
      bool isUpdateHistoryList, SgbData data, int index) async {
    var prevPlaying = player.playing;
    if (!isUpdateHistoryList) {
      await sgbContainer.updatePlayList(historyList);
      isUpdateHistoryList = true;
    }
    await Future.delayed(Duration.zero);
    var id = data.id.toString();
    var preId = player.sequenceState!.currentSource!.tag!.id.toString();
    if (id != preId) {
      await player.seek(Duration.zero, index: index);
    }
    // await sgbContainer.player.value.load();
    if (prevPlaying) {
      player.play();
    }
    Get.toNamed("/playerPage")!.then((value) {
      initdata();
    });
  }
}
