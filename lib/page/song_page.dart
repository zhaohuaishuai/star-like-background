import "package:flutter/material.dart";
import "../widget/new_box.dart";
import "../config/size.dart";
import "package:get/get.dart";
import 'package:just_audio/just_audio.dart';
import '../container/sgbContainer.dart';
import '../widget/play_list.dart';
import '../widget/common.dart';
import 'package:rxdart/rxdart.dart' as RXX;
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/services.dart';

class SongPage extends StatefulWidget {
  const SongPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SongPage();
  }
}

class _SongPage extends State<SongPage> {
  final sgbContainer = Get.find<SgbContainer>();
  final AudioPlayer player = Get.find<SgbContainer>().player.value;
  //底部列表是否展示
  bool showBootSheet = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  initPlayer() async {}
  ScrollController scrollController = ScrollController();
  Stream<PositionData> get _positionDataStream => RXX.CombineLatestStream
      .combine3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //后退按钮和菜单按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: Size.navBarButtonSize,
                  height: Size.navBarButtonSize,
                  child: NewBox(
                      child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Get.back();
                    },
                  )),
                ),
                Builder(builder: (context) {
                  return InkWell(
                    onTap: () {
                      // if(showBootSheet){
                      //   setState(() {
                      //     showBootSheet = false;
                      //     Get.back();
                      //     return;
                      //   });
                      //   return;
                      // }
                      setState(() {
                        showBootSheet = true;
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext buildContext) {
                              return Container(
                                height: 350.0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('歌单列表',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    Obx(
                                      () => PlayList(
                                          height: 300.0,
                                          player: player,
                                          scrollController: scrollController,
                                          playList: sgbContainer.currendList.value,
                                          onTab: (index) {
                                            if (index != player.currentIndex) {
                                              player.seek(Duration.zero,
                                                  index: index);
                                            }
                                            setState(() {
                                              showBootSheet = false;
                                            });
                                            Get.back();
                                          }),
                                    )
                                  ],
                                ),
                              );
                            },
                            elevation: 0.5);
                      });
                    },
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: NewBox(child: Icon(Icons.menu)),
                    ),
                  );
                }),
              ]),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: NewBox(
                    child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/lighthouse-square.jpg",
                        height: 320,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 250,
                                child: StreamBuilder(
                                  stream: player.currentIndexStream,
                                  builder: (context, snapshot) {
                                    var index = snapshot.data;
                                    if (index == null) {
                                      return Container();
                                    }
                                    var data =
                                        sgbContainer.currendList.value[index];
                                    return Text("${data.xuhao}.${data.title}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                            overflow: TextOverflow.ellipsis));
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: NewBox(
                        child: const Icon(Icons.volume_up),
                      ),
                    ),
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
                  StreamBuilder<LoopMode>(
                    stream: player.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      const icons = [
                        Icon(Icons.repeat, color: Colors.black),
                        Icon(Icons.repeat, color: Colors.red),
                        Icon(Icons.repeat_one, color: Colors.green),
                      ];
                      const cycleModes = [
                        LoopMode.off,
                        LoopMode.all,
                        LoopMode.one,
                      ];
                      final index = cycleModes.indexOf(loopMode);
                      return InkWell(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: NewBox(
                            child: icons[index],
                          ),
                        ),
                        onTap: () {
                          player.setLoopMode(cycleModes[
                              (cycleModes.indexOf(loopMode) + 1) %
                                  cycleModes.length]);
                        },
                      );
                    },
                  ),
                  InkWell(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: NewBox(
                            child: Text('谱',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center))),
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) {
                            var url = sgbContainer.currendList
                                .value[player.currentIndex ?? 0].dmturl!.gepuUrl;
                            
                            return SafeArea(
                              child: Container(
                                  child: Stack(
                                children: [
                                  Container(
                                    child: ListView(
                                      children: [
                                        FadeInImage.memoryNetwork(
                                            width:
                                                MediaQuery.of(context).size.width,
                                            fit: BoxFit.fill,
                                            placeholder: kTransparentImage,
                                            image: "${url}")
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                Get.back();
                                              },
                                            )),
                                      ),
                                      width: 40,
                                      height: 40,
                                      right: 10,
                                      top: 10),
                                ],
                              )),
                            );
                          });
                    },
                  ),
                  InkWell(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: InkWell(
                          child: NewBox(
                              child: Text('词',
                                  style: TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center)),
                          onTap: () {
                            var lyric = sgbContainer.currendList
                                .value[player.currentIndex ?? 0].dmturl!.lyric;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                    child: Scaffold(
                                  backgroundColor: Colors.white,
                                  body: Container(
                                    child: Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                child: Icon(
                                                  Icons.copy_all,
                                                  size: 30,
                                                ),
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(text: lyric));
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                child: Icon(
                                                  Icons.close,
                                                  size: 30,
                                                ),
                                                onTap: () {
                                                  Get.back();
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: ListView(
                                          children: [
                                            Text("$lyric",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16, height: 2))
                                          ],
                                        ),
                                      ))
                                    ]),
                                  ),
                                ));
                              },
                            );
                          },
                        )),
                    onTap: () {},
                  ),
                  StreamBuilder<bool>(
                    stream: player.shuffleModeEnabledStream,
                    builder: (context, snapshot) {
                      final shuffleModeEnabled = snapshot.data ?? false;
                      return InkWell(
                        child: SizedBox(
                            width: 50,
                            height: 50,
                            child: NewBox(
                              child: shuffleModeEnabled
                                  ? const Icon(Icons.shuffle, color: Colors.orange)
                                  : const Icon(Icons.shuffle, color: Colors.grey),
                            )),
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
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                height: 38,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: NewBox(
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
                            player.seek(newPosition);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ControlButtons(player),
            const SizedBox( height:10),
        ]
        )
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 20,
        ),

        SizedBox(
          width: 10,
        ),
        Expanded(
            child: StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => InkWell(
            child: SizedBox(
              width: 50,
              height: 50,
              child: NewBox(child: const Icon(Icons.skip_previous)),
            ),
            onTap: player.hasPrevious ? player.seekToPrevious : null,
          ),
        )),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  // margin: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: NewBox(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ))),
                );
              } else if (playing != true) {
                return InkWell(
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: NewBox(child: const Icon(Icons.play_arrow))),
                  onTap: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return InkWell(
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: NewBox(child: const Icon(Icons.pause))),
                  onTap: player.pause,
                );
              } else {
                return InkWell(
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: NewBox(
                          child: const Icon(
                        Icons.error,
                        color: Colors.black,
                      ))),
                  onTap: () {
                    player.seek(Duration.zero,
                        index: player.effectiveIndices!.first);
                  },
                );
              }
            },
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
            child: StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => InkWell(
            child: SizedBox(
                width: 50,
                height: 50,
                child: NewBox(
                  child: Icon(Icons.skip_next),
                )),
            onTap: player.hasNext ? player.seekToNext : null,
          ),
        )),
        SizedBox(
          width: 10,
        ),
        // Expanded(
        //     child: StreamBuilder<double>(
        //   stream: player.speedStream,
        //   builder: (context, snapshot) => InkWell(
        //     child: SizedBox(
        //       width: 50,
        //       height: 50,
        //       child: NewBox(
        //         child: Center(
        //           child: Text("${snapshot.data?.toStringAsFixed(1)}x",
        //               style: const TextStyle(fontWeight: FontWeight.bold)),
        //         ),
        //       ),
        //     ),
        //     onTap: () {
        //       showSliderDialog(
        //         context: context,
        //         title: "Adjust speed",
        //         divisions: 10,
        //         min: 0.5,
        //         max: 1.5,
        //         stream: player.speedStream,
        //         onChanged: player.setSpeed,
        //       );
        //     },
        //   ),
        // )),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
