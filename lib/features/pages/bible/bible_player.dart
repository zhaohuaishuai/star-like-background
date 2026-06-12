import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:m/core/utils/toast.dart';


class BiblePlayer {
static final AudioPlayer _audioPlayer = AudioPlayer();


  static Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  static Stream<bool> get playingStream => _audioPlayer.onPlayerStateChanged.map((event) => event == PlayerState.playing);

  // 加载状态
  static Stream<PlayerState> get playerState => _audioPlayer.onPlayerStateChanged.map((event) => event);

  static Future<void> seek(Duration duration) async {
    await _audioPlayer.seek(duration);
  }

  static Future<void> play(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  static Future<void> pause() async {
    await _audioPlayer.pause();
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
  }

 static String? _fullName;
 static String? _chapterSN;
 static String? get path => '$_fullName第$_chapterSN章';
 static String? get url => 'https://oss.top237.top/bible/汉语和合本-磐石版/$_fullName/$path.mp3';

  static Future<void> playBible(String fullName,String chapterSN) async {
      if(path == '$fullName第$chapterSN章'){
        if(_audioPlayer.state == PlayerState.playing){
          await pause();
        }else{
          await play(url!);
        }
        return;
     }
     if(path != '$fullName第$chapterSN章'){
      await stop();
     }
    _fullName = fullName;
    _chapterSN = chapterSN; 
    Toast.showToast('音频加载中...', ToastStatusEnum.info,const Duration(seconds: 2));
    await play(url!);
  }
}
