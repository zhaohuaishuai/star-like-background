import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../config/color.dart';
import '../container/sgbContainer.dart';
import './RotationWidget.dart';

class PlayerBottomBarr extends StatefulWidget {
  PlayerBottomBarr({
    Key? key
  }):super(key:key);

  @override
  _PlayerBottomBarr createState() {
    return _PlayerBottomBarr();
  }

}


class _PlayerBottomBarr extends State<PlayerBottomBarr> {
  AudioPlayer player = Get.find<SgbContainer>().player.value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.all(Radius.circular(27))
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white24,borderRadius: BorderRadius.all(Radius.circular(21))),
                width: 42,
                height: 42,
                child: Center(
                  child: RotationWidget(
                      onTap: (){
                        Get.toNamed("/playerPage");
                      },
                      child: Image.asset("assets/images/logo.png",width: 34,height: 34,)),
                ),
              ),
              StreamBuilder(
                  stream: player.sequenceStateStream,
                  builder: (content,snapshot){
                return Expanded(child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(snapshot.data?.currentSource?.tag.title??"暂无播放",textAlign: TextAlign.left,style: TextStyle(color: Colors.white70),),
                      Text(snapshot.data?.currentSource?.tag.displaySubtitle??"",textAlign: TextAlign.left,style: TextStyle(color: Colors.white60,fontSize: 12),)
                    ],
                  ),
                ),);
              }),
              Container(
                decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(21))),
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    StreamBuilder(
                      stream:player.positionStream,
                      builder: (context,snap) {
                        int duration = player.duration?.inSeconds ?? 0;

                        if (snap.hasData && duration != 0) {

                          int currentDuration = snap.data?.inSeconds ?? 0;
                          print( currentDuration / duration);
                          return SizedBox(
                            width: 42,
                            height: 42,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              value: currentDuration / duration,
                              color: Colors.white,
                              backgroundColor: Colors.white30,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }
                    ),
                    StreamBuilder(
                      stream: player.playingStream,
                      builder: (context,snap){
                        if(snap.data??false){
                          return InkWell(
                              onTap: (){
                                player.pause();
                              },
                              child: Icon(Icons.pause_rounded,size: 34,));
                        } else {
                          return InkWell(
                              onTap: (){
                                player.play();
                              },
                              child: Icon(Icons.play_arrow_sharp,size: 34,));
                        }
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}