import 'package:Shine_like_a_star/config/color.dart';
import 'package:Shine_like_a_star/widget/poster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/utils.dart';
import 'package:get/get.dart';
import '../widget/TouchCenterBack.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import '../widget/StarScaffold.dart';

class GeCi extends StatefulWidget {
  GeCi({Key? key}) : super(key: key);

  @override
  State<GeCi> createState() {
    return _GeCi();
  }
}

class _GeCi extends State<GeCi> {
  late final String lyric;
  late final String title;
  List<int> selectList = [];

  List<Widget> get LyricList {
    if (lyric == null) {
      return [];
    }
    List<Widget> _lyriclist = [];
    lyric.split("\n").asMap().forEach((key, value) {
      _lyriclist.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print("点击效果");
                setState(() {
                  if (selectList.indexOf(key) > -1) {
                    selectList =
                        selectList.where((element) => element != key).toList();
                    return;
                  }
                  var _selectList = selectList.map((element) => element)
                      .toList();
                  _selectList.add(key);
                  selectList = _selectList;
                });
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: selectList.indexOf(key) > -1 ? Colors.black54 : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 10,),
                    Icon(Icons.check, color: selectList.indexOf(key) > -1
                        ? Colors.white
                        : Colors.transparent),
                    Expanded(child: Container()),
                    Text("${value}",
                        style: TextStyle(
                            fontFamily: "WenQuanDengKuanWeiMiHei",
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            decoration: TextDecoration.none,
                            color: Colors.white)),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          ));
    });
    return _lyriclist;
  }

  String get selectLyric {
    var _lyric = "";
    lyric.split("\n").asMap().forEach((key, value) {
      if (selectList.indexOf(key) > -1) {
        _lyric += value + "\n";
      }
    });
    return _lyric;
  }

  void copyLyric() {
    Clipboard.setData(
        ClipboardData(text: selectLyric.length == 0 ? lyric : selectLyric))
        .then((_) {
      Get.snackbar('提示', '歌词复制成功',
          duration: Duration(milliseconds: 800),
          backgroundColor: Colors.white,
          icon: Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green,
          ),
          snackPosition: SnackPosition.BOTTOM);
    }).catchError((_) {
      Get.snackbar('提示', '歌词复制失败',
          duration: Duration(milliseconds: 800),
          backgroundColor: Colors.white,
          icon: Icon(
            Icons.close_outlined,
            color: Colors.red,
          ),
          snackPosition: SnackPosition.BOTTOM);
    });
  }


  void toPoster(){
    navigator!.push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            PosterContainer(
              posterStyle: PosterStyle(
                const EdgeInsets.all(20),
                18,
                Colors.black54,
              ),
              qrCodeUrl: "https://star.top237.top",
              title: title,
              lyric:selectList.length>0?selectLyric:lyric,

            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      lyric = Get.parameters['lyric'] as String;
      title = Get.parameters['title'] ?? '';
    });
    Jutils.setWebTitle("歌词-$title");
    MatomoTracker.instance
        .trackEvent(eventCategory: 'look', action: '歌词', eventName: title);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF362E2B), Color(0xFF000000)], // 渐变色
            stops: [0.0, 1.0], // 渐变位置
            begin: Alignment.topCenter, // 渐变起始位置
            end: Alignment.bottomCenter, // 渐变结束位置
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
                left: 0,
                right: 0,
                top: 0,
                child: ListView(
                  padding: EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery
                          .of(context)
                          .padding
                          .top + 40,
                      bottom: 80,
                      left: 0,
                      right: 0),
                  children: LyricList,
                )),
            //AppBarWidget
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: AppBarWidget(
                  title: Text(
                    title,
                    style: TextStyle(color: Colors.white),
                  ),

                )),
            //BottomWidget
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                      bottom: 0, left: 0, right: 0, top: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00000000), // rgba(0, 0, 0, 0.0) 对应的颜色代码
                        Color(0xFF000000), // #000000 对应的颜色代码
                        Color(0xFF000000), // #000000 对应的颜色代码
                      ],
                      stops: [0.0, 0.3, 1.0], // 渐变的停止点
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CapsuleButton(
                        text: "复制歌词",
                        onPressed: () {
                          copyLyric();
                        },
                      ),


                      CapsuleButton(
                        text: "歌词图片",
                        onPressed: () {
                          toPoster();
                        },
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget {
  Widget? title;
  List<Widget>? actions;

  AppBarWidget({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    double bottom = 30;
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery
              .of(context)
              .padding
              .top, bottom: bottom),
      width: double.infinity,
      height: kToolbarHeight + MediaQuery
          .of(context)
          .padding
          .top + bottom,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF362E2B), // 起始颜色
            Color(0xFF362E2B), // 中间颜色
            Color(0x00362E2B), // 结束颜色（透明）
          ],
          stops: [0.0, 0.6, 1.0], // 渐变的停止点
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title ??
              SizedBox(
                width: 0,
                height: 0,
              ),
          Expanded(child: Container()),
          Row(
            children: actions ?? [],
          )
        ],
      ),
    );
  }
}

class CapsuleButton extends StatelessWidget {
  String text;
  Function onPressed;

  CapsuleButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          onPressed();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // 圆角半径
            ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(color: Color(0xFFD6D3CD), width: 2), // 按钮边框
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Text(
            text,
            style: TextStyle(color: Color(0xFFD6D3CD)),
          ),
        ));
  }
}
//
// class LyricList extends StatelessWidget {
//   String lyric;
//   List<int> selectIndex;
//   Function onTap;
//   LyricList({super.key, required this.lyric, required this.selectIndex,required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     if (lyric == null) {
//       return [];
//     }
//     var index = -1;
//     return lyric.split("\n").map((element) {
//       index++;
//       return Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             print("点击效果");
//
//           },
//           splashColor: Colors.blue.withAlpha(30),
//           // 水波纹颜色
//           highlightColor: Colors.blue.withAlpha(20),
//           // 高亮颜色
//           borderRadius: BorderRadius.circular(8),
//           // 圆角边框
//           child: Container(
//             decoration: BoxDecoration(
//               color: selectList.indexOf(index) > -1 ? Color(0xFF1C1914) : null,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Icon(Icons.check, color: Colors.white),
//                 Expanded(child: Container()),
//                 Text("${element}-${index}",
//                     style: TextStyle(
//                         fontFamily: "WenQuanDengKuanWeiMiHei",
//                         fontWeight: FontWeight.w400,
//                         fontSize: 20,
//                         height: 2.3,
//                         decoration: TextDecoration.none,
//                         color: Colors.white)),
//                 Expanded(child: Container()),
//               ],
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }
// }
