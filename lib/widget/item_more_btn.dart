import 'package:Shine_like_a_star/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../type/sgbType.dart';
import 'package:Shine_like_a_star/utils/downUtils.dart'
    if (dart.library.html) 'package:Shine_like_a_star/utils/downHtmlUtils.dart';
import '../storage/sgbStorage.dart';
import '../widget/status/empty.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

class ItemMoreBtn extends StatelessWidget {
  final SgbData sgbData;
  final MaterialColor? color;
  ItemMoreBtn({Key? key, required this.sgbData, this.color}) : super(key: key);
  Key selectKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_outlined,
        color: color ?? Colors.white,
      ),
      itemBuilder: (_) {
        return [
          PopupMenuItem(
            child: Text("查看歌谱"),
            value: {
              'type': 'gepu',
              'url': sgbData.dmturl.gepuUrl,
              'title': sgbData.full_title,
            },
          ),
          PopupMenuItem(
            child: Text("查看歌词"),
            value: {
              'type': 'geci',
              'lyric': sgbData.dmturl.lyric,
              'title': sgbData.title
            },
          ),
          PopupMenuItem(
            child: Text("下载歌曲"),
            value: {
              'type': 'downMp3',
              'mp3Url': sgbData.dmturl.adUrl,
              'title': sgbData.title
            },
          ),
          PopupMenuItem(
            child: Text("下载歌谱"),
            value: {
              'type': 'downGepu',
              'gePuUrl': sgbData.dmturl.gepuUrl,
              'title': sgbData.title
            },
          ),
          PopupMenuItem(child: Text("加入歌单"), value: {'type': 'addGeDan'}),
        ];
      },
      onSelected: (value) async {
        switch (value['type'] as String) {
          case 'gepu':
            Get.toNamed(RouteName.GePuPage.value, parameters: value);
            // MatomoTracker.instance.trackEvent(
            //     eventCategory: 'look', action: '歌谱', eventName: value['title']);
            break;
          case 'geci':
            Get.toNamed(RouteName.GeCiPage.value, parameters: value);
            // MatomoTracker.instance.trackEvent(
            //     eventCategory: 'look', action: '歌词', eventName: value['title']);
            break;
          case 'downMp3':
            downFile.down(
                'mp3/${value['title']}.mp3',
                value['mp3Url'] as String
            );
            MatomoTracker.instance.trackEvent(
                eventCategory: 'down',
                action: '下载mp3',
                eventName: value['title']);
            break;
          case 'downGepu':
            if (PlatformUtils.isAndroid || PlatformUtils.isIOS) {
              downFile.savePhont(
                  '${value['title']}.jpg', value['gePuUrl'] as String);
            } else {
              downFile.down(
                  '${value['title']}.jpg', value['gePuUrl'] as String);
            }

            MatomoTracker.instance.trackEvent(
                eventCategory: 'down',
                action: '下载歌谱',
                eventName: value['title']);

            break;
          case 'addGeDan':
            SgbStorage sgbStorage = SgbStorage();
            List<SongListData> list = sgbStorage.songList;
            await Get.bottomSheet(SongListSelectList(
                list: list,
                onCreated: () {
                  print("创建回调");
                  list = sgbStorage.songList;
                },
                onConfirm: (selectedList) {
                  Get.back();
                  selectedList.forEach((SongListData element) {
                    String ids = element.ids as String;
                    if (ids.indexOf(sgbData.id) == -1) {
                      if (ids == '') {
                        ids += '${sgbData.id}';
                      } else {
                        ids += ',${sgbData.id}';
                      }
                      element.ids = ids;
                      sgbStorage.addSongList(element);
                    } else {
                      Get.snackbar('提示', '当前歌单已经添加${sgbData.full_title}这首赞美了。',
                          backgroundColor: Colors.white,
                          icon: Icon(
                            Icons.warning,
                            color: Colors.yellowAccent,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          duration: Duration(milliseconds: 1000));
                    }
                  });
                }));
            break;
        }
      },
    );
  }
}

class SongListSelectList extends StatefulWidget {
  final List<SongListData> list;
  final onConfirm;
  final onCreated;
  SongListSelectList(
      {Key? key, required this.list, this.onConfirm, this.onCreated})
      : super(key: key);
  @override
  _SongListSelectListState createState() {
    return _SongListSelectListState();
  }
}

class _SongListSelectListState extends State<SongListSelectList> {
  List<SongListData> selectedList = [];
  SgbStorage sgbStorage = SgbStorage();
  List<SongListData> list = [];
  @override
  void initState() {
    super.initState();
    list = sgbStorage.songList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkChange(bool selected, SongListData item) {
    if (selected) {
      setState(() {
        selectedList =
            selectedList.where((element) => element.id != item.id).toList();
        print(selectedList.length);
      });
    } else {
      setState(() {
        selectedList.add(item);
        print(selectedList.length);
      });
    }
  }

  void createSongList() {
    Get.toNamed(
      RouteName.GeDanEditPage.value,
    )!
        .then((_) {
      widget.onCreated();
      setState(() {
        list = sgbStorage.songList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "歌单列表",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      createSongList();
                    },
                    child: Text(
                      "创建歌单",
                      style: TextStyle(color: Colors.lightBlue),
                    )),
                TextButton(
                    onPressed: () {
                      if (widget.onConfirm != null) {
                        widget.onConfirm(selectedList);
                      }
                    },
                    child: Text(
                      "确定",
                      style: TextStyle(color: Colors.lightBlue),
                    ))
              ],
            ),
          ),
          list.length > 0
              ? Expanded(
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, int index) {
                        SongListData item = list[index];
                        bool selected = selectedList
                            .any((element) => element.id == item.id);
                        return ListTile(
                          title: Text(item.title as String),
                          selected: selected,
                          leading: Checkbox(
                            value: selected,
                            onChanged: (value) {
                              checkChange(selected, item);
                            },
                          ),
                          onTap: () {
                            checkChange(selected, item);
                          },
                        );
                      }),
                )
              : Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyWidget(),
                      TextButton(
                          onPressed: () {
                            createSongList();
                          },
                          child: Text(
                            "创建歌单",
                            style: TextStyle(fontSize: 20),
                          ))
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
