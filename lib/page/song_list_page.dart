
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import '../config/color.dart';
import '../widget/play_list_page.dart';
import '../type/sgbType.dart';


class SongListPage extends StatefulWidget {
  SongListPage({Key? key}) : super(key: key);
  @override
  _SongListPageState createState() {
    return _SongListPageState();
  }
}

class _SongListPageState extends State<SongListPage> {
  late SgbContainer sgbContainer = Get.find<SgbContainer>();
  final AudioPlayer player = Get.find<SgbContainer>().player.value;
  final List<String> songListIds = [];
  @override
  void initState() {
    print(Get.parameters['ids']);
    if(Get.parameters['ids'] != null){
      songListIds.addAll(Get.parameters['ids']!.split(","));
    }
    super.initState();
  }

  List<SgbData> get _currentList {
    return songListIds.map((String id)  {
      return sgbContainer.sgb.value.firstWhere((SgbData element) => element.id == id);
    }).toList();
  }

  get title => Get.parameters['title']??'歌单';
  get coverImg => Get.parameters['coverImg']??'https://www.top237.top/lsky/2023/01/06/63b7bf356d8e4.jpg';
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isUpdateHistoryList = false;
    return Container(
      decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
      child: PlayListPage(
              coverImg: coverImg,
              list: _currentList,
              title: title,
              BackIconShow: true,
              player: player,
              onTap: (SgbData data,int index) async {
                sgbContainer.songLostToPlayerPage(isUpdateHistoryList, data, index, _currentList, () { });
              },
    )
    );

  }
}
