import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
class RotationWidget extends StatefulWidget {
  final Widget child;
  final bool isRota;
  final Function? onTap;
  RotationWidget({Key? key,required this.child,this.isRota = false,this.onTap }) : super(key: key);
  @override
  _RotationWidgetState createState() {
    return _RotationWidgetState();
  }
}

class _RotationWidgetState extends State<RotationWidget> with TickerProviderStateMixin{
  late AnimationController  animController ;
  AudioPlayer player = Get.find<SgbContainer>().player.value;
  @override
  void initState() {
    animController = AnimationController(vsync: this,duration: Duration(seconds: 60));
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        print("status is completed");
        //重置起点
        animController.reset();
        //开启
        animController.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        print("status is dismissed");
      } else if (status == AnimationStatus.forward) {
        print("status is forward");
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
        print("status is reverse");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    // if(widget.isRota){
    //   animController.forward();
    // }else {
    //   animController.stop();
    // }

    // TODO: implement build
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (content,snapshot){
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing??false;
        if(playing){
          animController.forward();
        }else {
          animController.stop();
        }
        return RotationTransition(
          turns: animController,
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius:BorderRadius.circular(60),
            child: InkWell(
                onTap: (){
                  widget.onTap!();
                },
                child: widget.child),
          ),
        );
      },

    );
  }
}



