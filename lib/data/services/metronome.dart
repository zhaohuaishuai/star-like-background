import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

enum Rhythm {
  oneFourth,
  twoFourth,
  threeFourth,
  fourFourth,
  threeSixth,
  sixEighth;

  String get label => switch (this) {
        Rhythm.oneFourth => '1/4',
        Rhythm.twoFourth => '2/4',
        Rhythm.threeFourth => '3/4',
        Rhythm.fourFourth => '4/4',
        Rhythm.threeSixth => '3/6',
        Rhythm.sixEighth => '6/8',
      };

  int get modeCount => switch (this) {
        Rhythm.oneFourth => 1,
        Rhythm.twoFourth => 2,
        Rhythm.threeFourth => 3,
        Rhythm.fourFourth => 4,
        Rhythm.threeSixth => 3,
        Rhythm.sixEighth => 6,
      };
}

enum MetronomeSound {
  click,
  female;

  String get label => switch (this) {
        MetronomeSound.click => '默认',
        MetronomeSound.female => '人声',
      };

  List<String> get assetsPaths => switch (this) {
        MetronomeSound.click => List.generate(7, (int index) {
            if (index == 0) {
              return '';
            }
            if (index == 1) {
              return  'mp3/metronome_ding.mp3';
            }
            return  'mp3/metronome_1.mp3';
          }),
        MetronomeSound.female => List.generate(7, (int index) {
            if (index == 0) {
              return '';
            }
            return 'mp3/sp$index.wav';
          }),
      };


  List<AssetSource> get assetsSources => switch (this) {
        MetronomeSound.click => List.generate(7, (int index) {
            if (index == 0) {
              return AssetSource('');
            }
            if (index == 1) {
              return AssetSource('mp3/metronome_ding.mp3');
            }
            return AssetSource('mp3/metronome_1.mp3');
          }),
        MetronomeSound.female => List.generate(7, (int index) {
            if (index == 0) {
              return AssetSource('');
            }
            return AssetSource('mp3/sp$index.wav');
          }),
      };

  play(AudioPlayer audioPlayer, int currentBeat) async {
    Source soundPath = assetsSources[currentBeat];
    debugPrint('播放的音频 soundPath:$soundPath');
    await audioPlayer.stop();
    await audioPlayer.play(soundPath);
    
  }

  pause(AudioPlayer audioPlayer) {
    audioPlayer.pause();
  }

  stop(AudioPlayer audioPlayer) async {
    await audioPlayer.stop();
  }
}

class MetronomeService extends GetxService {
  static bool isInit = false;

  Future<MetronomeService> init() async {
    if (isInit) {
      return MetronomeService.to;
    }
    isInit = true;
    return this;
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  static MetronomeService get to => Get.find<MetronomeService>();

  Rx<double> bpm = 60.0.obs;
  Rx<Rhythm> selectedRhythm = Rhythm.fourFourth.obs;
  Rx<bool> isPlaying = false.obs;
  Rx<int> count = 0.obs;
  static double maxBpm = 160.0;
  static double minBpm = 20.0;

  int get currentBeat => (count.value % selectedRhythm.value.modeCount) + 1;
  // 速度的定义是 1 分钟内播放的节拍数。 1 分钟 等于 60 秒， 1 秒 等于 1000 毫秒 总共是 6000 毫秒
  // 已知 速度是 69 那么 1 拍的时间就是 60 * 1000 / 69 = 86ms
  int get gapTime => (60 * 1000) ~/ bpm.value.toInt();

  Rx<MetronomeSound> selectedMetronomeSound = MetronomeSound.click.obs;
  double get playbackRate => math.max(2 * (bpm.value / maxBpm), 1.5);

  
  @override 
  // ignore: must_call_super
  onInit() async { 
    bpm.listen((event) {
      stop();
      audioPlayer.setPlaybackRate(playbackRate);
    });
  }

  play() {
    isPlaying.value = true;
    _timeLoop(true);
  }

  stop() {
    audioPlayer.stop();
    isPlaying.value = false;
    count.value = 0;
  }

  switchPlay() {
    if (isPlaying.value) {
      stop();
    } else {
      play();
    }
  }

  int _nextBeatTime = 0;
  _timeLoop(bool? isFirst) async {
    if (isFirst == true) {
      await audioPlayer.setSourceAsset(selectedMetronomeSound.value.assetsPaths[currentBeat]); 
      await selectedMetronomeSound.value.play(audioPlayer, currentBeat);  
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    _nextBeatTime = now + gapTime;
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if (!isPlaying.value) {
        timer.cancel();
        stop();
        return;
      } 
      int current = DateTime.now().millisecondsSinceEpoch;
      if (current >= _nextBeatTime && isPlaying.value) {
        onBeat();
        _nextBeatTime += gapTime;
      }
    });
  }

  onBeat() async { 
     count.value++;
     int now = DateTime.now().millisecondsSinceEpoch; 
     await selectedMetronomeSound.value.play(audioPlayer, currentBeat); 
     debugPrint('执行 onBeat 耗时:${now - DateTime.now().millisecondsSinceEpoch}, 间隔：$gapTime,第 $currentBeat 拍');
    
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
