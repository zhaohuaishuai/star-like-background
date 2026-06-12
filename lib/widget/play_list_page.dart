import 'package:flutter/material.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import '../config/color.dart';
import '../type/sgbType.dart';
import 'package:just_audio/just_audio.dart';

import 'item_more_btn.dart';

class PlayListPage extends StatelessWidget {
  final String coverImg;
  final List<dynamic> list;
  final String title;
  final bool? BackIconShow;
  final Function? onTap;
  final int? playIndex;
  final String? listTitle;
  final AudioPlayer player;
  PlayListPage(
      {Key? key,
      required this.coverImg,
      required this.list,
      required this.title,
      required this.player,
      this.BackIconShow = false,
      this.onTap,
      this.playIndex,
      this.listTitle = '播放列表',

      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackIconShow == true
                        ? Material(
                            color: Colors.transparent,
                            child: IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 22,
                                )),
                          )
                        : Container(),
                    //rgba(57, 77, 120, 1)
                    // Icon(
                    //   Icons.settings,
                    //   size: 22,
                    //   color: AppColor.titleFontColor,
                    // ),
                    // SizedBox(width: 10),
                    // Icon(Icons.ac_unit,
                    //     size: 22, color: AppColor.titleFontColor)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${title}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                decoration: TextDecoration.none,
                                overflow: TextOverflow.ellipsis
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: "共",
                                  style: TextStyle(color: Colors.white),
                                  children: [
                                TextSpan(
                                    text: "${list.length.toString()}",
                                    style: TextStyle(color: Colors.red)),
                                TextSpan(
                                  text: "首",
                                  style: TextStyle(color: Colors.white),
                                )
                              ]))
                        ],
                      ),
                    ),
                    Container(
                      width: 65,
                      height: 65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: coverImg.startsWith("http")?Image.network(coverImg): Image.asset(coverImg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            Expanded(
              child: PlayList(
                list: list,
                playIndex: playIndex,
                listTitle: listTitle,
                player: player,
                onTap: (SgbData data, int index) {
                  onTap!(data, index);
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
}


class PlayList extends StatefulWidget {
  final List<dynamic> list;
  final Function? onTap;
  final int? playIndex;
  final String? listTitle;
  final AudioPlayer? player;
  ScrollController? controller;
  final onInit;
  final bool? isAutoCurIndexTop;
  final int? topIndex;
  PlayList({Key? key,
    required this.list,
    this.onTap,
    this.playIndex = -1,
    this.listTitle = '播放列表',
    this.player,
    this.controller,
    this.onInit,
    this.isAutoCurIndexTop,
    this.topIndex,
  }) : super(key: key);

  @override
  _PlayListState createState() {
    return _PlayListState();
  }
}

class _PlayListState extends State<PlayList> {
  ScrollController controller = ScrollController();
  double itemExtent = 66;
  GlobalKey currentKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(widget.isAutoCurIndexTop!=null){
        // BuildContext robj = currentKey!.currentContext as BuildContext;
        // print("--->${robj}");
        print("--->${currentKey.currentContext}");
        int index = widget.player!.currentIndex as int;
        print("当前的index值--->${index}");
        if(widget!.isAutoCurIndexTop == true){
          if(widget.topIndex!=null){
            index = widget.topIndex as int;
          }
          controller.jumpTo(itemExtent * index);
        };
      }

    });

  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        gradient: AppColor.appListBackgroundGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.listTitle.toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: Colors.black54),
              ),
            ],
          ),
          Flexible(
              child: StreamBuilder(
                  stream: widget.player?.currentIndexStream,
                  builder: (context,snapshot) {
                    var cId ="-1";
                    if(widget.player != null ){
                      cId = widget.player!.sequenceState!.currentSource!.tag.id.toString();
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      itemCount: widget.list.length,
                      controller: controller,
                      itemExtent: itemExtent,
                      // semanticChildCount:10,
                      itemBuilder: (_, i) {
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            key: cId == widget.list[i].id?currentKey:ValueKey(i),
                            title: InkWell(
                              onTap: (){
                                widget.onTap!(widget.list[i] as SgbData, i as int);
                              },
                              child: Container(
                                child: Row(
                                  // rgba(57, 77, 120, 1)
                                  children: [
                                    Text(widget.list[i].xuhao.toString(),
                                        style: TextStyle(color: AppColor.xuhaoFontColor)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: Text(widget.list[i].title,
                                            style:
                                            TextStyle(color: AppColor.titleFontColor),
                                            overflow: TextOverflow.ellipsis)),
                                    SizedBox(width: 10,),
                                    Builder(
                                      builder: (BuildContext builder) {
                                        var lId = widget.list[i].id.toString();
                                        if(cId == lId){
                                          return  Text("正在播放",style: TextStyle(fontSize: 12,color: Colors.grey),);
                                        }else {
                                          return Container();
                                        }
                                      },
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            // title: Text(widget.list[i].title,style:TextStyle(color: AppColor.titleFontColor)),
                            trailing: ItemMoreBtn(sgbData: widget.list[i] ,color: Colors.grey,),
                            // subtitle: Builder(
                            //   builder: (BuildContext builder) {
                            //     var lId = widget.list[i].id.toString();
                            //     if(cId == lId){
                            //       return Text("正在播放");
                            //     }else {
                            //       return Container();
                            //     }
                            //   },
                            // ),
                          ),
                        );
                      },
                    );
                  }
              )),
        ]),
      ),
    );
  }
}



class PlayLyricList extends StatelessWidget {
  final List<dynamic> list;
  final Function? onTap;
  final int? playIndex;
  final String? listTitle;
  final  player;
  PlayLyricList(
      {Key? key,
        required this.list,
        this.onTap,
        this.playIndex = -1,
        this.listTitle = '播放列表',
        this.player
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        gradient: AppColor.appListBackgroundGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listTitle.toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: Colors.black54),
              ),
            ],
          ),
          Flexible(
              child: StreamBuilder(
                  stream: player?.currentIndexStream,
                  builder: (context,snapshot) {
                    var cId ="-1";
                    if(player != null ){
                      cId = player.sequenceState!.currentSource!.tag.id.toString();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              onTap!(list[i] as SgbData, i as int);
                            },
                            title: Container(
                              child: Row(
                                // rgba(57, 77, 120, 1)
                                children: [
                                  Text(list[i].xuhao.toString(),
                                      style: TextStyle(color: AppColor.xuhaoFontColor)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Text(list[i].title,
                                          style:
                                          TextStyle(color: AppColor.titleFontColor),
                                          overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                            trailing: ItemMoreBtn(sgbData: list[i] ,color: Colors.grey,),
                            subtitle: Builder(
                              builder: (BuildContext builder) {
                                return Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:list[i].dmturl.splitLyric??[],
                                  ),
                                );
                                // var lId = list[i].id.toString();
                                // if(cId == lId){
                                //
                                // }else {
                                //   return Container();
                                // }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
              )),
        ]),
      ),
    );
  }
}
