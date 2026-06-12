import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import '../type/sgbType.dart';

class PlayList extends StatelessWidget {
  final onTab;
  final player;
  final scrollController;
  final sgbContainer = Get.find<SgbContainer>();
  final height;
  final List<SgbData> playList;
  PlayList(
      {Key? key,
      this.player,
      this.scrollController,
      this.onTab,
      this.height,
      required this.playList})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var list = (currentIndex){
      return ListView.builder(
          controller: scrollController,
          itemCount: playList.length,
          itemBuilder: (_, i) {
            return ListTile(
              title: Text("${playList[i].xuhao}.${playList[i].title}"),
              trailing: TrailingWiget(
                  index: i, currentIndex: currentIndex),
              dense: false,
              onTap: () {
                onTab == null ? '' : onTab(i);
              },
              onLongPress: () {},
            );
          });
    };
    // TODO: implement build
    return Container(
      height: height,
      child:player == null? list(-1):StreamBuilder<SequenceState?>(
        stream: player!.sequenceStateStream,
        builder: (context, snapshot) {
          // final state = snapshot.data;
          return list(player.currentIndex??-1);
        },
      ),
    );
  }
}

class TrailingWiget extends StatelessWidget {
  final int index;
  final int currentIndex;
  final sgbContainer = Get.find<SgbContainer>();
  TrailingWiget({Key? key, required this.index, required this.currentIndex})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var trailing = !(sgbContainer.currendList.value[index]!.years == '')
        ? Get.find<SgbContainer>().currendList.value[index]!.years
        : '';
    if (currentIndex == index) {
      trailing = trailing??'' +'  正在播放';
      return Text(trailing);
    }
    return Text('');
  }
}
