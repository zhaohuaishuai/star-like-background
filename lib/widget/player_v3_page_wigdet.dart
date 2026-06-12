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
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
class PlayerPage extends StatefulWidget {
  final AudioPlayer player;
  final BackBtnType? backBtnType;
  PlayerPage({Key? key, required this.player, this.backBtnType})
      : super(key: key);
  @override
  _PlayerPageState createState() {
    return _PlayerPageState();
  }
}

class _PlayerPageState extends State<PlayerPage> with TraceableClientMixin {
  SgbContainer controller = Get.find<SgbContainer>();
  final List<SgbData> sgb = Get.find<SgbContainer>().sgb.value;
  SgbData getSgbById(String id) {
    return sgb.firstWhere((element) {
      return element.id == id;
    });
  }

  @override
  String get traceTitle => "播放页面";
  @override
  String get traceName => "播放页面";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showMinuteInputDialog(BuildContext context) {
    Duration duration = Duration(minutes: 0);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('设置音乐停止时间'),
          content: MinuteInputWidget(
            onChanged: (value){
              duration = Duration(minutes: int.parse(value));
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.cancelTimer();
                Navigator.of(context).pop();
              },
              child: Text('取消定时'),

            ),
            TextButton(
              onPressed: () {

                Navigator.of(context).pop();
              },
              child: Text('取消'),

            ),
            TextButton(
              onPressed: () {
                if(duration.inSeconds > 0){
                  print("设置关闭时间");
                  controller.startTimer(duration);
                }
                Navigator.of(context).pop();
              },
              child: Text('确定'),

            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StarScaffold(
      leading:  IconButton(onPressed: () {
        print("点击了一下？");
        if (widget.backBtnType == null || widget.backBtnType == BackBtnType.back) {
          Get.back();
          return;
        }
        Get.toNamed(RouteName.firstPage.value);
      }, icon: Icon(
          (widget.backBtnType == null ||
              widget.backBtnType ==
                  BackBtnType.back)
              ? Icons.keyboard_arrow_down
              : Icons.home,
          color: Colors.white,
          size: 35),),
      actions: [
              Row(children: [
              Obx((){
                return Text(controller.diffDuration.value,style: TextStyle(color: Colors.white,fontSize: 12),);
              }),
              IconButton(onPressed: (){
              _showMinuteInputDialog(context);
              }, icon: Icon(Icons.timer))
              ],),
                StreamBuilder<SequenceState?>(
                  stream: widget.player.sequenceStateStream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                      var currendSgbData = null;
                      try {
                        currendSgbData = getSgbById(snapshot.data!.currentSource.tag.id);
                      } catch (err) {}

                      return IconButton(
                          onPressed:() {
                            Clipboard.setData(ClipboardData(
                                text:
                                'https://star.top237.top/#/playnew/${currendSgbData.id}/${currendSgbData.shiji_index}/shiji'))
                                .then((_) {
                              Get.snackbar('提示', '分享链接复制成功',
                                  duration:
                                  Duration(milliseconds: 800),
                                  backgroundColor: Colors.white,
                                  icon: Icon(
                                    Icons
                                        .check_circle_outline_rounded,
                                    color: Colors.green,
                                  ),
                                  snackPosition:
                                  SnackPosition.BOTTOM);
                            }).catchError((_) {
                              Get.snackbar('提示', '分享链接复制失败，可以重新试一下',
                                  duration:
                                  Duration(milliseconds: 800),
                                  backgroundColor: Colors.white,
                                  icon: Icon(
                                    Icons.close_outlined,
                                    color: Colors.red,
                                  ),
                                  snackPosition:
                                  SnackPosition.BOTTOM);
                            });
                          },
                          icon:Icon(Icons.share)
                      );
                  }
                ),

      ],
      child: StreamBuilder<SequenceState?>(
          stream: widget.player.sequenceStateStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget Loading = Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
            if (snapshot.data == null) {
              return Loading;
            }
            if (Get.find<SgbContainer>().sgb.value.length == 0) {
              return Loading;
            }
            var currendSgbData = null;
            try {
              currendSgbData = getSgbById(snapshot.data!.currentSource.tag.id);
            } catch (err) {}

            if (currendSgbData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("不知道发生了什么？点击下面按钮回到首页",
                        style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Get.toNamed(RouteName.firstPage.value);
                        },
                        child: Text("回首页",
                            style: TextStyle(
                                color: Colors.white, fontSize: 10))),
                  ],
                ),
              );
            }
            try {
              Jutils.setWebTitle(currendSgbData.title);
            } catch (err) {
              print("发生错误了-->${err.toString()}");
            }
            return Column(
              children: [
                SizedBox( height: 60,),
                Container( child: DaZhuanPan()),
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
                              overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
                  ),
                ),
                // 歌词
                Expanded(
                    child: GeCiWigdet(currendSgbData: currendSgbData)),
                ToolBar(
                    player: widget.player,
                    currendSgbData: currendSgbData),
                Material(
                    color: Colors.transparent,
                    child: ProgressBar(
                      player: widget.player,
                    )),
                ControlButtons(
                  widget.player,
                  sgbData: currendSgbData,
                ),
                SizedBox(
                  height: 30,
                )
              ],
            );
          }),
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
        padding: EdgeInsets.only(top: 0),
        children: [
          Text(currendSgbData.dmturl!.lyric ?? '',
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  height: 2,
                  fontFamily: "WenQuanDengKuanWeiMiHei"))
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

                Icon(Icons.repeat, color: Colors.white70),
                Icon(Icons.repeat, color: Colors.white),
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
              onTap: () {
                var lyric = currendSgbData.dmturl.lyric;
                Get.toNamed(RouteName.GeCiPage.value, parameters: {
                  'lyric': lyric,
                  'title': currendSgbData.full_title
                });
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: ItemMoreBtn(
              sgbData: currendSgbData,
            ),
          )
        ],
      ),
    );
  }
}

// 进度条
class ProgressBar extends StatefulWidget {
  final AudioPlayer player;
  ProgressBar({Key? key, required this.player}) : super(key: key);

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
  ControlButtons(this.player, {Key? key, required this.sgbData})
      : super(key: key);
  ScrollController scrollController = ScrollController();
  Future<void> next() async {
    sgbContainer.seekToNext();
  }

  Future<void> to(int index) async {
    sgbContainer.seek(index);
  }

  Future<void> pre() async {
    sgbContainer.seekToPrevious();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Builder(builder: (context) {
            return InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return StreamBuilder(
                        stream: player.sequenceStateStream,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data == null) {
                            return Container();
                          }
                          var list = sgbContainer.transitionSgbDataList(
                              snapshot.data.effectiveSequence);
                          return Container(
                            height: 350.0,
                            child: PlayList(
                                controller: scrollController,
                                player: player,
                                list: list,
                                isAutoCurIndexTop: true,
                                topIndex: list.indexWhere((element) => element.id == sgbData.id),
                                onTap: (SgbData data, int index) async {
                                  print(data.full_title);
                                  // 如果开启随机播放模式那么需要根据id来查询一个当前播放列表的索引值
                                  if(player.shuffleModeEnabled){
                                    index = sgbContainer.querySgbDataIdtoIndex(data.id);
                                  }

                                  if (index != player.currentIndex) {
                                    await to(index);
                                  }
                                  Get.back();
                                }),
                          );
                        });
                  },
                  elevation: 0.5,
                ).then((value) {
                  print('打开底部列表-->$value');
                });
              },
              child: Icon(Icons.menu, color: Colors.white, size: 50),
            );
          }),
        ),
        Expanded(
            child: StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => InkWell(
            child:
                const Icon(Icons.skip_previous, color: Colors.white, size: 50),
            onTap: pre,
          ),
        )),
        Expanded(
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              // || processingState == ProcessingState.buffering
              if (playerState != null) {
                sgbContainer.updateHistory(playerState);
              }

              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  // margin: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      clipBehavior: Clip.hardEdge,
                      child: Center(
                        child: Image.asset(
                          "assets/images/dengta.gif",
                          fit: BoxFit.contain,
                          scale: 2.2,
                          width: 200,
                          height: 200,
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
            onTap: next,
          ),
        )),
        Expanded(
          child: Material(
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

                Get.toNamed(RouteName.GePuPage.value,
                    parameters: {'url': sgbData.dmturl.gepuUrl,'title':sgbData.full_title});

                // Get.to(()=>GePu(url:sgbData.dmturl.gepuUrl),transition: Transition.downToUp);
              },
            ),
          ),
        ),
      ],
    );
  }
}


class MinuteInputWidget extends StatefulWidget {
  void Function(String string) ?onChanged;
  MinuteInputWidget({ Key? key, this.onChanged});

  @override
  _MinuteInputWidgetState createState() => _MinuteInputWidgetState();
}

class _MinuteInputWidgetState extends State<MinuteInputWidget> {
  final TextEditingController _controller = TextEditingController();

  void _setMinute(int minutes) {
    setState(() {
      _controller.text = minutes.toString();
      if(widget.onChanged!=null){
        widget.onChanged!(minutes.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),],
          decoration: InputDecoration(
            labelText: '分钟数',
            border: OutlineInputBorder(),
          ),
          onChanged: (value){

            if(widget.onChanged!=null){
              widget.onChanged!(value);
            }
          },
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton(15),
            _buildQuickButton(30),
            _buildQuickButton(45),
            _buildQuickButton(60),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(int minutes) {
    return ElevatedButton(
      onPressed: () => _setMinute(minutes),
      child: Text('${minutes}分钟'),
    );
  }
}