
import 'package:Shine_like_a_star/utils/utils.dart';
import 'package:flutter/material.dart';
import '../config/color.dart';
import 'package:get/get.dart';
import '../container/sgbContainer.dart';
import '../widget/common.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as RXX;
import 'package:flutter/services.dart';
import '../widget/item_more_btn.dart';
import '../widget/play_list_page.dart';
import '../widget/daZhuanPan.dart';
import '../type/sgbType.dart';
import '../storage/sgbStorage.dart';

class PlayerPage extends StatefulWidget {
  final AudioPlayer player;
  PlayerPage({Key? key,required this.player}) : super(key: key);
  @override
  _PlayerPageState createState() {
    return _PlayerPageState();
  }
}

class _PlayerPageState extends State<PlayerPage> {
  SgbContainer controller = Get.find<SgbContainer>();
  final List<SgbData> sgb = Get.find<SgbContainer>().sgb.value;

  SgbData getSgbById(String id){
    return sgb.firstWhere((element) {
      return element.id == id;
    });
  }
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
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: AppColor.appPlayerBackgroundGradient,
          ),
          child: SafeArea(
            child: StreamBuilder<SequenceState?>(
              stream: widget.player.sequenceStateStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print("snapshot.hasError-->${snapshot.hasError}");
                print("snapshot.data-->${snapshot.data}");
                Widget Loading = Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                );
                if(snapshot.data == null ){
                  return Loading;
                }
                if(Get.find<SgbContainer>().sgb.value.length ==0){
                  return Loading;
                }
                var currendSgbData = null;
                try{
                  currendSgbData = getSgbById(snapshot.data!.currentSource.tag.id);
                }catch(err){}
                print("currendSgbData-->$currendSgbData");
                if(currendSgbData == null){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("不知道发生了什么？点击下面按钮回到首页",style: TextStyle(color: Colors.white,fontSize: 16)),
                        SizedBox(height: 30,),
                        ElevatedButton(
                            onPressed:(){
                              Get.toNamed(RouteName.firstPage.value);
                            } ,
                            child:Text("回首页",style: TextStyle(color: Colors.white,fontSize: 10))),
                      ],
                    ),
                  );
                }
                try{
                  Jutils.setWebTitle(currendSgbData.title);
                }catch(err){
                  print("发生错误了-->${err.toString()}");
                }
                return Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Material(
                                  color: Colors.transparent,
                                  // borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Icon(Icons.keyboard_arrow_down,
                                        color: Colors.white, size: 35),
                                  )),
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                    onTap: () {},
                                    child: Icon(Icons.share_outlined,
                                        color: Colors.white, size: 26)),
                              )
                            ],
                          )),

                      Container(
                          height: 300,
                          child: DaZhuanPan()
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                currendSgbData.full_title.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // 歌词
                      Expanded(child: GeCiWigdet(currendSgbData: currendSgbData)),

                      Expanded(child: Column(
                        children: [
                          ToolBar(player: widget.player, currendSgbData: currendSgbData),
                          Material(color: Colors.transparent, child: ProgressBar(player: widget.player,)),
                          ControlButtons(widget.player,sgbData: currendSgbData,),
                        ],
                      ))
                    ],
                  ),
                );
              }
            ),
          ),
        ),

    );
  }
}

class GeCiWigdet extends StatelessWidget {
  const GeCiWigdet({
    Key? key,
    required this.currendSgbData,
  }) : super(key: key);

  final currendSgbData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          Text(
              currendSgbData.dmturl!.lyric??'',
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  height: 2,
                  fontFamily: "WenQuanDengKuanWeiMiHei")
          )
        ],
      ),
    );
  }
}
// 工具条
class ToolBar extends StatelessWidget {
  const ToolBar({
    Key? key,
    required this.player,
    required this.currendSgbData,
  }) : super(key: key);

  final AudioPlayer player;
  final SgbData currendSgbData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: const Icon(Icons.volume_up, color: Colors.white),
              onTap: () {
                showSliderDialog(
                  context: context,
                  title: "调整音量",
                  divisions: 10,
                  min: 0.0,
                  max: 1.0,
                  stream: player.volumeStream,
                  onChanged: player.setVolume,
                );
              },
            ),
          ),
          StreamBuilder<LoopMode>(
            stream: player.loopModeStream,
            builder: (context, snapshot) {
              final loopMode = snapshot.data ?? LoopMode.off;
              const icons = [
                Icon(Icons.repeat, color: Colors.white),
                Icon(Icons.repeat, color: Colors.white70),
                Icon(Icons.repeat_one, color: Colors.white),
              ];
              const cycleModes = [
                LoopMode.off,
                LoopMode.all,
                LoopMode.one,
              ];
              final index = cycleModes.indexOf(loopMode);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  child: icons[index],
                  onTap: () {
                    player.setLoopMode(cycleModes[
                    (cycleModes.indexOf(loopMode) + 1) %
                        cycleModes.length]);
                  },
                ),
              );
            },
          ),
          StreamBuilder<bool>(
            stream: player.shuffleModeEnabledStream,
            builder: (context, snapshot) {
              final shuffleModeEnabled = snapshot.data ?? false;
              return InkWell(
                child: shuffleModeEnabled
                    ? const Icon(Icons.shuffle, color: Colors.white)
                    : const Icon(Icons.shuffle, color: Colors.white70),
                onTap: () async {
                  final enable = !shuffleModeEnabled;
                  if (enable) {
                    await player.shuffle();
                  }
                  await player.setShuffleModeEnabled(enable);
                },
              );
            },
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: Text('词',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              onTap: (){
                var lyric = currendSgbData.dmturl!.lyric;
                Get.toNamed(
                  RouteName.GeCiPage.value,
                  parameters: {'lyric':lyric,'title':currendSgbData.full_title}
                );
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: ItemMoreBtn(sgbData: currendSgbData ,),
          )
        ],
      ),
    );
  }
}

// 进度条
class ProgressBar extends StatefulWidget {
  final AudioPlayer player;
  ProgressBar({Key? key,required this.player}) : super(key: key);

  @override
  _ProgressBarState createState() {
    return _ProgressBarState();
  }
}
class _ProgressBarState extends State<ProgressBar> {

  @override
  void initState() {
    super.initState();
  }

  final sgbContainer = Get.find<SgbContainer>();

  Stream<PositionData> get _positionDataStream => RXX.CombineLatestStream
      .combine3<Duration, Duration, Duration?, PositionData>(
         widget.player.positionStream,
      widget.player.bufferedPositionStream,
      widget.player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(left: 17, right: 17),
      child: SizedBox(
        height: 38,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                duration: positionData?.duration ?? Duration.zero,
                position: positionData?.position ?? Duration.zero,
                bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                onChangeEnd: (newPosition) {
                  widget.player.seek(newPosition);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
// 控制器
class ControlButtons extends StatelessWidget {
  final SgbData sgbData;
  final AudioPlayer player;
  final sgbContainer = Get.find<SgbContainer>();
  final SgbStorage sgbStorage = SgbStorage();
  ControlButtons(this.player, {Key? key,required this.sgbData}) : super(key: key);
  ScrollController scrollController =ScrollController();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child:  Material(
          color: Colors.transparent,
          child: InkWell(
            child: Container(
              child: Text('谱',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  textAlign: TextAlign.center),
            ),
            onTap: () {
              Get.toNamed(RouteName.GePuPage.value,parameters:{'url':sgbData.dmturl.gepuUrl,'title':sgbData.full_title});
            },
          ),
        ),),
        Expanded(
            child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => InkWell(
              child:
                  const Icon(Icons.skip_previous, color: Colors.white, size: 50),
              onTap: player.hasPrevious ? player.seekToPrevious : null,
            ),
        )),
        Expanded(
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              // 更新播放历史的关键代码
              sgbContainer.updateHistory(playerState as PlayerState);
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  // margin: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      clipBehavior:Clip.hardEdge,
                      child: Center(
                        child: Image.asset(
                          "assets/images/dengta.gif",
                          fit: BoxFit.contain,
                          scale: 2.2,
                          width: 200,height: 200,
                        ),
                      ),
                    ),
                  ),
                );
              } else if (playing != true) {
                return InkWell(
                  child: const Icon(
                    Icons.play_circle,
                    color: Colors.white70,
                    size: 80,
                  ),
                  onTap: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return InkWell(
                  child: const Icon(Icons.pause_circle,
                      color: Colors.white70, size: 80),
                  onTap: player.pause,
                );
              } else {
                return InkWell(
                  child: const Icon(Icons.error, color: Colors.white, size: 80),
                  onTap: () {
                    player.seek(Duration.zero,
                        index: player.effectiveIndices!.first);
                  },
                );
              }
            },
          ),
        ),
        Expanded(
            child: StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => InkWell(
            child: const Icon(Icons.skip_next, color: Colors.white, size: 50),
            onTap: player.hasNext ? player.seekToNext : null,
          ),
        )),
        Expanded(child: Builder(builder: (context) {
          return InkWell(
            onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext buildContext) {

                      return StreamBuilder(
                        stream: player.sequenceStateStream,
                        builder: (BuildContext context,AsyncSnapshot snapshot) {
                          var list = sgbContainer.transitionSgbDataList(snapshot.data.effectiveSequence);
                          print('currentIndex-->${snapshot.data.currentIndex}');


                          return Container(
                            height: 350.0,
                            child:  PlayList(
                                controller: scrollController,
                                player: player,
                                list:list,
                                isAutoCurIndexTop:true,
                                onTap: (SgbData data,int index) {
                                  if (index != player.currentIndex) {
                                    player.seek(Duration.zero,
                                        index: index);
                                  }
                                  Get.back();
                                }
                            ),
                          );
                        }
                      );
                    },
                    elevation: 0.5,

                ).then((value){
                      print('打开底部列表-->$value'
                    );
                });

            },
            child: Icon(Icons.menu,color:Colors.white,size:50),
          );
        }),)

      ],
    );
  }
}
