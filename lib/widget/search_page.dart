import 'dart:async';
import 'dart:math';
import 'package:Shine_like_a_star/container/sgbContainer.dart';
import 'package:Shine_like_a_star/type/sgbType.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
import 'package:flutter/material.dart';
import '../config/color.dart';
import '../widget/search.dart';
import 'package:get/get.dart';
import '../widget/play_list_page.dart';
import '../storage/sgbStorage.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

class SearchPage extends StatefulWidget {
  // 是否展示历史记录
  bool? showHistory;
  // 是否展示退出按钮
  bool? showBackBtn;
  // 选择回调，如何不加侧默认跳转到播放页
  final onTap;

  SearchPage({Key? key, this.showHistory, this.showBackBtn, this.onTap})
      : super(key: key);
  @override
  _SearchPageState createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage>
   with SingleTickerProviderStateMixin, TraceableClientMixin {
  final sgbController = Get.find<SgbContainer>();
  final player = Get.find<SgbContainer>().player.value;
  final streamController = StreamController();
  List<SgbData> get sgb => sgbController.sgb.value;
  late TabController tabController;
  get activeTabIndex => _activeTabIndex;
  int _activeTabIndex = 0;
  set activeTabIndex(index) => _activeTabIndex = index;
  int indexSearchCount = 0;
  int lyricSearchCount = 0;
  @override
  String get traceTitle => "搜索页面";
  @override
  String get traceName => "搜索页面";

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    tabController.addListener(() {
      setState(() {
        activeTabIndex = tabController.index;
      });
    });
  }

  SgbStorage sgbStorage = SgbStorage();
  @override
  void dispose() {
    super.dispose();
  }

  var isCurPlayList = false;
  var currentShiJiIndex = -1;
  toPlayerPage(SgbData data, int index) async {
    if (widget.onTap != null) {
      widget.onTap(data, index);
      return;
    }

    var prevPlaying = player.playing;
    var findSgb = sgb.where((e) {
      return e.shiji_index == data.shiji_index;
    }).toList();
    // 当前选择的诗集歌单，不是当前的显示列表的歌单时
    if (currentShiJiIndex != data.shiji_index) {
      await sgbController.updatePlayList(findSgb);
      currentShiJiIndex = data.shiji_index;
      sgbController.sgbStorage.activeIndex = data.shiji_index;
    }
    var id = data.id.toString();
    var preId = player.sequenceState!.currentSource!.tag!.id.toString();
    if (id != preId) {
      await player.seek(Duration.zero,
          index: findSgb.indexWhere((element) => element.id == data.id));
      if (prevPlaying) {
        await player.play();
      }
    }
    MatomoTracker.instance.trackSearch(searchKeyword: findSgb[0].title);
    sgbStorage.searchHistory = id;
    Get.toNamed("/playerPage");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StarScaffold(
        leading: Container(
          child: (widget.showBackBtn == null
              ? true
              : widget.showBackBtn as bool)
              ? Row(
            children: [
              BackButton(
                color: Colors.white,
                onPressed: () {
                  Get.back();
                },
              )
            ],
          )
              : null,
        ),
        child: Column(
          children: [

            //搜索框
            Padding(
              padding: EdgeInsets.only(top: 48,bottom: 10, left: 24,right:24),
              child: SearchBarWidget(
                enabled: true,
                autofocus: true,
                onchangeValue: (event) {
                  print("$event");
                  streamController.add(event);
                },
                onEditingComplete: () {
                  print("onEditingComplete:");
                },
                onClear: () {
                  streamController.add("");
                },
              ),
            ),

            StreamBuilder(
                stream: streamController.stream,
                builder: (_, event) {
                  var findList = [];
                  var lyricList = [];
                  if (event.data.toString().trim() != '' ) {
                    findList = sgb.where((element) {
                      return (element.xuhao.toString().padLeft(3,'0') + element.title)
                              .indexOf(event.data.toString()) !=
                          -1;
                    }).toList();

                    lyricList = sgb
                        .where((element) {
                          return element.dmturl.lyric
                                  .toString()
                                  .indexOf(event.data.toString()) !=
                              -1;
                        })
                        .toList()
                        .map((e) {
                          var lyric = e.dmturl.lyric.split("\n");
                          var lyricStr = lyric
                              .where((element) =>
                                  element.indexOf(event.data.toString()) != -1)
                              .map((element) {
                            RegExp reg = RegExp(
                                "([.]*)(${event.data.toString()})([.]*)");
                            int i = element.indexOf(reg);
                            int e = i + event.data.toString().length;
                            String startStr = element.substring(0, i);
                            String endStr = '';
                            List<TextSpan> lt = [];
                            // print("开始位置：${i}");
                            // print("结束位置：${e}");
                            // print("标题：${element}");

                            if (i == 0 && e != event.data.length) {
                              endStr =
                                  element.substring(i + e, element.length - 1);
                              lt.addAll([
                                TextSpan(
                                    text: event.data.toString(),
                                    style: TextStyle(color: Colors.red)),
                                TextSpan(text: endStr),
                              ]);
                            } else if (i == 0 && e == event.data.length) {
                              lt.addAll([
                                TextSpan(
                                    text: event.data.toString(),
                                    style: TextStyle(color: Colors.red)),
                              ]);
                            } else if ((i + e) >= element.length) {
                              lt.addAll([
                                TextSpan(text: startStr),
                                TextSpan(
                                    text: event.data.toString(),
                                    style: TextStyle(color: Colors.red)),
                              ]);
                            } else {
                              endStr =
                                  element.substring(i + e, element.length - 1);
                              lt.addAll([
                                TextSpan(text: startStr),
                                TextSpan(
                                    text: event.data.toString(),
                                    style: TextStyle(color: Colors.red)),
                                TextSpan(text: endStr),
                              ]);
                            }

                            // print("开始位置的字：${startStr}，结束位置的字：${endStr}");
                            return RichText(text: new TextSpan(children: lt));
                            ;
                          }).toList();
                          e.dmturl.splitLyric = lyricStr;
                          return e;
                        })
                        .toList();
                  }
                  else {
                    findList = sgb;
                  }

                  if(event.data == null){
                    findList = sgb;
                  }


                  indexSearchCount = findList.length;
                  lyricSearchCount = lyricList.length;
                  return (event.data.toString().trim() == '' ||
                              event.connectionState ==
                                  ConnectionState.waiting) &&
                          (widget.showHistory == null
                              ? true
                              : widget.showHistory as bool)
                      ? InputHistory(
                          key: UniqueKey(),
                          onTap: toPlayerPage,
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: activeTabIndex == 0
                                                ? BorderSide(
                                                    width: 3,
                                                    color: Colors.blueAccent)
                                                : BorderSide(
                                                    width: 0,
                                                    color:
                                                        Colors.transparent))),
                                    child: TextButton(
                                      onPressed: () {
                                        tabController.animateTo(0);
                                        setState(() {
                                          activeTabIndex = 0;
                                        });
                                      },
                                      child: Text("标题和索引搜索${indexSearchCount}条",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      style: ButtonStyle(),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: activeTabIndex == 1
                                                ? BorderSide(
                                                    width: 3,
                                                    color: Colors.blueAccent)
                                                : BorderSide(
                                                    width: 0,
                                                    color:
                                                        Colors.transparent))),
                                    child: TextButton(
                                        onPressed: () {
                                          tabController.animateTo(1);
                                          setState(() {
                                            activeTabIndex = 1;
                                          });
                                        },
                                        child: Text("歌词搜索${lyricSearchCount}条",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600))),
                                  )
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: tabController,
                                  children: [
                                    PlayList(
                                      key: UniqueKey(),
                                      list: findList,
                                      listTitle: "按标题和索引搜索结果",
                                      onTap: toPlayerPage,
                                    ),
                                    PlayLyricList(
                                      key: UniqueKey(),
                                      list: lyricList,
                                      listTitle: "按歌词搜索结果",
                                      onTap: toPlayerPage,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                  // PlayLyricList(key:UniqueKey(),list:lyricList,listTitle:"搜索结果")
                  if (event.hasData) {
                    if (event.data == '') return InputHistory();
                    var findList = sgb.where((element) {
                      return element.full_title
                              .indexOf(event.data.toString()) !=
                          -1;
                    }).toList();
                    print(findList.length);
                    return Expanded(
                      child: PlayList(list: findList, listTitle: "搜索结果"),
                    );
                  }
                  return InputHistory();
                })
          ],
        ));
  }
}

class InputHistory extends StatefulWidget {
  Function? onTap;
  InputHistory({Key? key, this.onTap}) : super(key: key);

  @override
  _InputHistoryState createState() {
    return _InputHistoryState();
  }
}

class _InputHistoryState extends State<InputHistory> {
  List<SgbData> _seacherHistoryList = [];
  List<SgbData> get seacherHistoryList => _seacherHistoryList
      .getRange(
          0, _seacherHistoryList.length <= 10 ? _seacherHistoryList.length : 10)
      .toList();

  @override
  void initState() {
    super.initState();
    _seacherHistoryList = sgbStorage.searchHistory;
  }

  @override
  void dispose() {
    super.dispose();
  }

  SgbStorage sgbStorage = SgbStorage();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                Text(
                  "搜索历史",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            children: [
              ...List.generate(
                  seacherHistoryList.length,
                  (index) {
                    return GestureDetector(
                      onTap: (){
                        if (widget.onTap != null) {
                          widget.onTap!(seacherHistoryList[index], index);
                        }
                      },
                      child: Chip(
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.black87),
                        // 文字标签
                        label: Text(seacherHistoryList[index].full_title.toString()),
                        // 删除按钮，添加后回自动设置 Icon
                        onDeleted: () {
                          sgbStorage.delSeacrchHistory(
                              seacherHistoryList[index].id.toString());
                          print("remove id");
                          setState(() {
                            _seacherHistoryList = sgbStorage.searchHistory;
                          });
                        },
                      ),
                    );
              })
            ],
          ),
        ],
      ),
    );
  }
}

class SearchResult extends StatefulWidget {
  SearchResult({Key? key}) : super(key: key);

  @override
  _SearchResultState createState() {
    return _SearchResultState();
  }
}

class _SearchResultState extends State<SearchResult> {
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
    // TODO: implement build
    return Container(
      child: ListView.builder(
          itemCount: 10,
          itemBuilder: (_, i) {
            return Text("133");
          }),
    );
  }
}
