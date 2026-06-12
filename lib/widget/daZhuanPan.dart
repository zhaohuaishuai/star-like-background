import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import "package:get/get.dart";
import '../container/sgbContainer.dart';
import '../widget/RotationWidget.dart';
import 'dart:async';
import  'package:audioplayers/audioplayers.dart' as AudioPlayers;
class DaZhuanPan extends StatefulWidget {
  DaZhuanPan({Key? key}) : super(key: key);

  @override
  _DaZhuanPanState createState() {
    return _DaZhuanPanState();
  }
}

class _DaZhuanPanState extends State<DaZhuanPan> {
  SgbContainer contoller = Get.find<SgbContainer>();
  AudioPlayer player = Get.find<SgbContainer>().player.value;
  bool flag = false;
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
            width: 200,
            height: 260,
            child: Center(
              child: Column(children: [
                  RotationWidget(
                      isRota: true,
                      child: Image.asset("assets/images/border_logo.png")
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Switch(
                      value: flag,
                      onChanged: (val){
                        setState(() {
                          flag = val;
                        });
                      },
                    ),
                    Text("呼吸模式",style: TextStyle(color: Colors.white),)
                  ])
              ],),
            ),
          )),
          Positioned(
              top:46,
              child:AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: !flag ? Container(
                width: 120,
                height: 120,
                child: Center(child: Image.asset("assets/images/logo.png")),
              ):
            HuXiBall(),
          ) )
          ,
          // Positioned(
          //   bottom: 0,
          //   child: Row(children: [
          //     Switch(
          //       value: flag,
          //       onChanged: (val){
          //         setState(() {
          //           flag = val;
          //         });
          //       },
          //     ),
          //     Text("呼吸模式",style: TextStyle(color: Colors.white),)
          //   ],))

        ],
      ),
    );
  }
}


class HuXiBall extends StatefulWidget {
  const HuXiBall({
    Key? key,
  }) : super(key: key);

  @override
  _HuXiBall createState() {
    return _HuXiBall();
  }

}

class _HuXiBall extends State<StatefulWidget> with SingleTickerProviderStateMixin  {
  late AnimationController _controller ;
  String statusText = '';
  late AudioPlayers.AudioPlayer _player;
  late Timer timer;
  late int count = 0;
  late int time = 1;
  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    // _player = Get.find<SgbContainer>().huxiAudioPlayer;
    _player = new AudioPlayers.AudioPlayer();
    _controller = new AnimationController(vsync: this,duration: Duration(seconds: 4));
    _controller.addStatusListener((status) {
      print("动画的状态$status");
    });
    _controller.addListener(() {

      switch(_controller.status){
        case AnimationStatus.forward:
          setState(() {
            count = 3 - ( 4 * _controller.value ).toInt()+1;
          });
          break;

        case AnimationStatus.reverse:

          setState(() {
            count = ( 8 * _controller.value ).toInt()+1 ;
          });
          break;
        case AnimationStatus.dismissed:
          setState(() {
            time+=1;
          });
      }

    });



    _player.onPlayerComplete.listen((event) {
      audioPlayerDrive();
    });

    _player.onPositionChanged.listen((event) {
      // print("播放时长-->" + event.inSeconds.toString());

      if(event.inSeconds >=4 && event.inSeconds < 11){
        setState(() {
          count = 7 - ( event.inSeconds - 4 ).toDouble().ceil();
        });
        // hold
        // print("hold" + event.inSeconds.toString());
        if(statusText != '保持'){
          setState(()  {
            statusText = '保持';
          });

        }

      }else if (event.inSeconds >= 11 && event.inSeconds <=19){

        // print("ex"+ event.inSeconds.toString());
        // ex

        if(statusText != '吐'){
          _controller.duration = Duration(seconds: 8);
          _controller.reverse();
          setState(()  {
            statusText = '吐';
          });

        }

      } else {
        // print("in"+ event.inSeconds.toString());
        // in
        if(statusText != '吸'){
          _controller.duration = Duration(seconds: 4);
          _controller.forward();
          setState(()  {
            statusText = '吸';
          });
        }


      }

    });


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // anm();
      audioPlayerDrive();
    });

  }
  // 音频驱动方法
  void audioPlayerDrive() async {
    AudioPlayers.Source source = AudioPlayers.AssetSource("mp3/inhale_exhale.mp3");
    await source.setOnPlayer(_player);
    _player.play(source);
  }

  // 动画驱动方法
  void anm  ()async{
    _controller.duration = Duration(seconds: 4);
    setState(()  {
      statusText = '吸';
    });

    AudioPlayers.Source source = AudioPlayers.AssetSource("mp3/inhale.mp3");
    await source.setOnPlayer(_player);
    _player.play(source);
    await _controller.forward();
    setState(() {
      statusText = '保持';
    });
    setState((){
      count = 7;
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if(count == 1){
          timer.cancel();
        }
        setState(() {
          count--;
        });
      });
    });

    await Future.delayed(Duration(seconds: 7));
    _controller.duration = Duration(seconds: 8);
    setState(() {
      statusText = '吐';
    });

    source = AudioPlayers.AssetSource("mp3/exhale.mp3");
    await source.setOnPlayer(_player);
    _player.play(source);
    await _controller.reverse();
    anm();
  }

  @override
  void dispose() {
    print("组件销毁--->");
    _controller.dispose();

    // if(timer !=null){
    //   timer.cancel();
    // }

    // _player.pause();
    // _player.stop();
    _player.release();
    // TODO: implement dispose
    super.dispose();

  }
@override
Widget build(BuildContext context) {
  return Stack(
    alignment: Alignment.center,
    clipBehavior:Clip.none,
    children:[
      ScaleTransition(
        scale: Tween(begin:0.5,end:1.0).animate(this._controller) ,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.lightBlue
          ),

        ),
      ),
      Positioned(child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation){
            return ScaleTransition(scale: animation,child:child);;
          },
          child: Text(count.toString(),key:ValueKey<int>(count),style:TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.w800)))),
      Positioned(
            bottom: -20,
            child: AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: Text(
                    "${time.toString()}次",
                    key:ValueKey<int>(time),
                    style:TextStyle(color:Colors.white)))),
      Positioned(
          top:-25,
          child: Text(statusText,style: TextStyle(color: Colors.white),))
    ],
  );
}
}





