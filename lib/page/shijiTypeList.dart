import 'package:Shine_like_a_star/page/song_page.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import '../config/color.dart';
import '../widget/play_list_page.dart';
import '../type/sgbType.dart';
import '../page/player_page.dart';

class ShiJiTypeList extends StatefulWidget {
  ShiJiTypeList({Key? key}) : super(key: key);

  @override
  _ShiJiTypeListState createState() {
    return _ShiJiTypeListState();
  }
}

class _ShiJiTypeListState extends State<ShiJiTypeList> {
  late SgbContainer sgbContainer = Get.find<SgbContainer>();
  final AudioPlayer player = Get.find<SgbContainer>().player.value;
  @override
  void initState() {
    super.initState();
  }

  List<SgbData> get _currentList => sgbContainer.currendList.value;

  get title => sgbContainer.activeShiJiName.value;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isCurPlayList = false;
    return Container(
        decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
        child:  StreamBuilder(
            stream: player.currentIndexStream,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              return PlayListPage(
                coverImg: "assets/images/cover.png",
                list: _currentList,
                title: title,
                BackIconShow: true,
                player: player,
                // playIndex: sgbContainer.playListActiveIndex.value.toInt() == sgbContainer.activeIndex.value.toInt() ?snapshot.data:-1,
                onTap: (SgbData data,int index) async {
                  var prevPlaying = player.playing;
                  // var isCurPlayList = data.shiji_index.toInt() != sgbContainer.playListActiveIndex.value.toInt();
                  // 当前选择的诗集歌单，不是当前的显示列表的歌单时
                  if(!isCurPlayList){
                    await sgbContainer.updatePlayList(sgbContainer.currendList.value);
                    isCurPlayList = true;
                  }
                  var id = data.id.toString();
                  var preId = player.sequenceState!.currentSource!.tag!.id.toString();
                  if(id != preId){
                    await player.seek(Duration.zero, index: index);
                    if(prevPlaying){
                      await player.play();
                    }
                  }
                  Get.toNamed("/playerPage");
                },
              );
            }),
          );

  }
}
