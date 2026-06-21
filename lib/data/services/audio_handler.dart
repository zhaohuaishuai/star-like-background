import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:m/data/module/audio_source_tag.dart';

import 'package:just_audio/just_audio.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/down_file.dart';

import 'package:m/data/module/song.dart';
import 'package:m/data/services/star_player.dart';

class StarAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  // AudioPlayer get player => _player;
  PlayMode get playMode => StarPlayer().playMode.value;

  StarPlayerAbstract starPlayer() => StarPlayer.to;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get playing => _player.playing;

  Stream<bool> get playingStream => _player.playingStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Duration? get duration => _player.duration;

  Stream<Duration?> get durationStream => _player.durationStream;

  AudioSource get palyerAudioSource => _player.audioSource!;

  ConcatenatingAudioSource audioSource = ConcatenatingAudioSource(children: []);

  static Future<StarAudioHandler> initAudioService() async {
    final session = await AudioSession.instance;

    await session.configure(const AudioSessionConfiguration.music());

    return await AudioService.init(
      builder: () => StarAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.star.audio',
        androidNotificationChannelName: '发光如星',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  StarAudioHandler() : super() {
    // 播放状态监听广播到前台服务界面
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    //  监听播放完成事件
    _initPlayEnd();
  }

  //  监听播放完成事件
  _initPlayEnd() {
    if (kIsWeb || !Platform.isIOS) {
      _notIosPlayEnd();
      return;
    }
    _iosPlayEnd();
  }

  void _notIosPlayEnd() {
    _player.setLoopMode(LoopMode.off);
    playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        starPlayer().autoNext();
      }
    });
  }

  void _iosPlayEnd() {
    _player.setLoopMode(LoopMode.all);
    bool isReplaceIng = false;

    _player.positionStream.listen((position) async {
      if (duration == null) return;
      if (position >= duration! - const Duration(seconds: 1)) {
        if (!isReplaceIng) {
          if (audioSource.sequence.isEmpty) {
            debugPrint('空的列表！');
            return;
          }
          isReplaceIng = true;
          debugPrint('播放完成！');
          await pause();

          PlayMode playMode = await starPlayer().autoNext();
          debugPrint('播放模式！$playMode');
          if (playMode == PlayMode.single) {
            isReplaceIng = false;
          }
        }
      }
    });

    _player.durationStream.listen((event) {
      if (event != null) {
        Song? currentSong = starPlayer().currentSong.value;
        if (currentSong != null) {
          isReplaceIng = false;
          mediaItem.add(MediaItem(
            id: currentSong.id,
            title: currentSong.fullTitle,
            artUri: Uri.parse(playCoverUrl),
            artist: currentSong.shijiname,
            duration: duration ?? const Duration(microseconds: 0),
          ));
        }
      }
    });
    _player.setAudioSource(audioSource);
  }

  // ignore: unused_element
  _handlerPlayEnd() async {
    // if (duration == null) return;
    // if (position >= duration! - const Duration(seconds: 1)) {

    if (audioSource.sequence.isEmpty) {
      debugPrint('空的列表！');
      return;
    }

    PlayMode playMode = await starPlayer().autoNext();
    debugPrint('播放模式！$playMode');
    if (playMode == PlayMode.single) {}
  }

  @override
  Future<void> play() {
    return _player.play();
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> seek(Duration position, {int? index}) {
    return _player.seek(position, index: index);
  }

  @override
  Future<void> skipToNext() {
    return starPlayer().next();
  }

  @override
  Future<void> skipToPrevious() {
    return starPlayer().previous();
  }

  @override
  Future<void> stop() => _player.stop();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToNext,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToPrevious,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> playYuanChang() async {
    await switchPlayTarget(PlayTargetEnum.yuanChang);
  }

  Future<void> playBanZou() async {
    await switchPlayTarget(PlayTargetEnum.banZou);
  }

  Future<void> switchPlayTarget(PlayTargetEnum playTarget) async {
   
    Duration position = _player.position;
    bool playing = _player.playing;
    await setAudioSource(playTarget: playTarget);
    await Future.delayed(const Duration(milliseconds: 900));
    await seek(position, index: 0);
    if(playing){
      await play();
    }
   
  }

  Future<void> setAudioSource({PlayTargetEnum? playTarget}) async {
    Song? currentSong = starPlayer().currentSong.value;
    AudioSource? source;
    if (playing) {
      await pause();
      await seek(Duration.zero);
    }

    if (playTarget == PlayTargetEnum.banZou) {
      bool isBanZou = currentSong!.dmtUrl.banZouUrl != null &&
          currentSong.dmtUrl.banZouUrl!.isNotEmpty;
      if (isBanZou) {
        source = await _getAudioSource(
            currentSong: currentSong, playUrl: currentSong.dmtUrl.banZouUrl);
      }
    } else {
      bool isAdUrl = currentSong!.dmtUrl.adUrl != null &&
          currentSong.dmtUrl.adUrl!.isNotEmpty;
      if (isAdUrl) {
        source = await _getAudioSource(currentSong: currentSong);
      }
    }

    if (kIsWeb || !Platform.isIOS) {
      await _setNotIosAudioSource(source, currentSong);
      return;
    }
    await _setIosAudioSource(source);
  }

  _setIosAudioSource(AudioSource? source) async {
    await audioSource.clear();

    if (source == null) {
      return;
    }
    await audioSource.add(source);
    await _player.seek(Duration.zero, index: 0);
  }

  _setNotIosAudioSource(AudioSource? source, Song currentSong) async {
    if (source == null) {
      return;
    }
    Duration? duration = await _player.setAudioSource(
      source,
      preload: true,
      initialIndex: 0,
      initialPosition: const Duration(seconds: 0),
    );
    mediaItem.add(MediaItem(
      id: currentSong.id,
      title: currentSong.fullTitle,
      artUri: Uri.parse(playCoverUrl),
      artist: currentSong.shijiname,
      duration: duration ?? const Duration(microseconds: 0),
    ));
  }

  void onClose() {
    _player.dispose();
  }

  Future<AudioSource> _getAudioSource(
      {required Song currentSong, String? playUrl}) async {
    UriAudioSource source;
    String adUrl = playUrl ?? currentSong.dmtUrl.adUrl!;
    var isExit = await DownFile.isUrlFileExists(url: adUrl);
    if (isExit) {
      source = AudioSource.file(
        await DownFile.getUrlFIlePath(url: adUrl),
        tag: AudioSourceTag(SourceEnum.local, currentSong),
      );
    } else {
      source = AudioSource.uri(
        Uri.parse(adUrl),
        tag: AudioSourceTag(SourceEnum.network, currentSong),
      );
      DownFile.downloadFile(adUrl, showLoading: false);
    }

    return source;
  }
}
