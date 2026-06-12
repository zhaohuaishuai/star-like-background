import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:m/core/utils/utils.dart';


enum HuXiStatusEnum {
  xi,
  ya,
  hu,
}

class AnimHuxiWidget extends StatefulWidget {
  final VoidCallback onClose;
  final bool?pageHide;
  final double size;
  const AnimHuxiWidget({super.key, required this.onClose,this.pageHide,this.size = 300});

  @override
  State<AnimHuxiWidget> createState() => _AnimHuxiWidgetState();
}

class _AnimHuxiWidgetState extends State<AnimHuxiWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final AnimationController _opacityController =
      AnimationController(vsync: this);
  late final AudioPlayer _player = AudioPlayer(
     
  );

  String statusText = '';
  int count = 1;
  int secondes = 1;
  Timer? timer;

  HuXiStatusEnum? status ;

  final _throttler = Throttler(millisecounds: 1000);

  @override
  void initState() {
    super.initState();
    
    initEvent();
    
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity:
          Tween<double>(begin: 1, end: 0.5).animate(_opacityController),
      child: StreamBuilder<Duration>(
          stream: _player.onPositionChanged,
          builder: (context, durSnapshot) {
            Color color =
                context.isDarkMode ? Colors.white54 : Colors.white70;
            return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Center(
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.8),
                            color.withOpacity(0.3),
                          ],
                          stops: [
                            _controller.value,
                            _controller.value + 0.08,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                statusText,
                                style: const TextStyle(fontSize: 32),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${secondes}s',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '$count次',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                widget.onClose();
                              },
                              icon: const Icon(
                                Icons.stop,
                                size: 24,
                              ))
                        ],
                      )),
                    ),
                  );
                });
          }),
    );
  }


  void initEvent() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    audioDive();
    _player.onPlayerStateChanged.listen((PlayerState event) { 
      debugPrint('onPlayerStateChanged: $event');
      if(event == PlayerState.completed){ 
        // setState(() {
        //   count += 1;
        // }); 
      }
    });
    
    _player.onPositionChanged.listen((Duration position) async {
      
      setSecondes(position.inSeconds);
      if(position.inSeconds == 0){
        if(status == HuXiStatusEnum.xi){
          return;
        }
        debugPrint('onDurationChanged: 吸');
        status = HuXiStatusEnum.xi; 
        onAnimationPlay();
        return; 
      }

      if(position.inSeconds == 4){ 
          if(status == HuXiStatusEnum.ya){
            return;
          }
          status = HuXiStatusEnum.ya;
          debugPrint('onDurationChanged: 压'); 
          onAnimationPlay();
          return;
      }

      if(position.inSeconds == 11){ 
        if(status == HuXiStatusEnum.hu){
          return;
        }
        status = HuXiStatusEnum.hu;
        debugPrint('onDurationChanged: 呼');
        onAnimationPlay();
        
        return;
      } 
      if(position.inMilliseconds >= 18900){ 
        debugPrint('onPositionChanged: 超过19秒, ${position.inMilliseconds }'); 
        _throttler.run(() {
          debugPrint(' 执行次数 $count');
          setState(() { 
            count += 1;
          });
        });
        return; 
      }
 
    }); 
  }

  void audioDive() async {
    
    Source source = AssetSource('mp3/inhale_exhale.mp3');
    await _player.play(source);  
  }

   Future<void> onAnimationPlay() async {
 
   switch(status){
    case HuXiStatusEnum.xi:
        _controller.duration = const Duration(seconds: 4);
        statusText = '吸'.tr;  
        await _controller.forward(); 
      break;
    case HuXiStatusEnum.ya:
        statusText = '压'.tr; 
        _opacityController.duration = const Duration(milliseconds: 700);
        _opacityController.repeat(reverse: true);
        await Future.delayed(const Duration(seconds: 7));
        _opacityController.reset();
      break;
    case HuXiStatusEnum.hu:
        _controller.duration = const Duration(seconds: 8); 
        statusText = '呼'.tr; 
        await _controller.reverse(); 
      break;
    default:
      break;
   }
   setState(() {
     
   }); 
   
  }
  

  Future<void> onAnimationPause() async {
    _player.pause();
    _player.seek(Duration.zero);
    _opacityController.reset();
    _controller.reset();
  }


  void setSecondes(int position){
 
    int  secon = 0 ;
    switch(status){ 
      case HuXiStatusEnum.xi:
        secon = 4 - position; 
        break;
      case HuXiStatusEnum.ya:
           secon = 11 - position; 
        break;
      case HuXiStatusEnum.hu:
          secon = 19 - position; 
        break;
          default:
        break;
    }
    secon = secon<=0 || secon == 19?1:secon;
    setState(() {
      secondes = secon;
    });
  }

  

  @override
  void dispose() {
    timer?.cancel(); 
    _player.stop();
    _controller.dispose();
    _opacityController.dispose();
    _player.dispose();
    _throttler.dispose();
    super.dispose();
  } 
}
