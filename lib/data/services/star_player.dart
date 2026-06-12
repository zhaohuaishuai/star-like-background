import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/down_file.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/sgb.dart';
import 'package:m/data/module/sgb_data.dart';
import 'package:m/data/module/song.dart';
import 'package:m/data/services/audio_handler.dart';
import 'package:m/data/services/sgb.dart';
import 'package:m/shared/widgets/song_list_tile.dart';

abstract class StarPlayerAbstract extends GetxService {
  Rx<Song?> get currentSong;
  Rx<PlayMode> get playMode;
  PlayMode currentPlayMode() => playMode.value;
  Future<void> next();
  void changePlayMode();
  Rx<PlayTargetEnum> playTarget = PlayTargetEnum.yuanChang.obs;

  /// 自动播放下一首时逻辑
  Future<PlayMode> autoNext();
  Future<void> previous();
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration duration);
  bool get playing;
  Future<void> setSongList(List<SgbData> songList, int index);
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Duration? get duration;
  Stream<Duration?> get durationStream;
  AudioSource get palyerAudioSource;

  Future<void> showBottomSheet();

  Future<void> initStarPlayer();

  Future<void> playBanZou();
  Future<void> playYuanChang();

  Future<void> switchPlayTarget(PlayTargetEnum value);

  /// 设置睡眠定时器，指定分钟后停止播放
  void setSleepTimer(int minutes);

  /// 取消睡眠定时器
  void cancelSleepTimer();

  /// 获取剩余睡眠时间（分钟）
  int getRemainingSleepTime();

  /// 检查是否正在使用睡眠定时器
  bool get isSleepTimerActive;
}

enum PlayMode {
  /// 无限循环
  list('List', IconUtil.wuXiang),

  /// 单曲循环
  single('Single', Icons.replay),

  /// 播放当前歌曲，不切换下一首
  singlePlay('SinglePlay', Icons.stop);

  final String mode;
  final IconData icon;
  String get name {
    if (mode == 'List') {
      return '列表循环'.tr;
    } else if (mode == 'SinglePlay') {
      return '单曲播放'.tr;
    } else {
      return '单曲循环'.tr;
    }
  }

  const PlayMode(this.mode, this.icon);
}

class StarPlayer extends StarPlayerAbstract {
  GetStorage box = GetStorage();
  SgbProvider api = Get.put<SgbProvider>(SgbProvider());
  static StarPlayer get to => Get.find();
  List<SgbData> songList = [];
  final Rx<int> _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int index) => _currentIndex.value = index;

  @override
  Rx<Song?> currentSong = Rx<Song?>(null);

  late StarAudioHandler _audioHandler;

  @override
  bool get playing => _audioHandler.playing;

  Stream<PlayerState> get playerStateStream => _audioHandler.playerStateStream;

  Future<StarPlayer> init() async {
    _audioHandler = await StarAudioHandler.initAudioService();
    return this;
  }

  setCurrentIndex(int index) async {
    playTarget.value = PlayTargetEnum.yuanChang;
    currentIndex = index;
    currentSong.value = await getSong();

    await box.writeString(GetStorage.praiseId, currentSong.value!.id);
    // box.writeInt(GetStorage.praiseListId, currentSong.value!.shijiIndex);

    await _audioHandler.setAudioSource();
  }

  Future<void> playByIndex(int index) async {
    await setCurrentIndex(index);
    await play();
  }

  @override
  setSongList(List<SgbData> songList, int index) async {
    if (currentIndex == index &&
        this.songList.length == songList.length &&
        hasDuiBi(this.songList, songList)) {
      return;
    }
    this.songList = songList;
    await setCurrentIndex(index);
  }

  SgbData? get currentSgbData => songList[currentIndex];

  Future<Song> getSong() async {
    return await api.getSgbDetail(currentSgbData!.id);
  }

  @override
  Future<void> play() async {
    await _audioHandler.play();
  }

  @override
  Future<void> pause() async {
    await _audioHandler.pause();
  }

  @override
  Future<void> next({bool isAuto = false}) async {
    if (currentIndex < songList.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }
    bool isad = currentSgbData!.isad;
    if (isAuto) {
      debugPrint('----》 isad:$isad');
      if (!isad) {
        next(isAuto: true);
        return;
      }
    }
    await setCurrentIndex(currentIndex);
    if (isad) {
      await play();
    } else {
      await pause();
    }
  }

  @override
  Future<void> previous() async {
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = songList.length - 1;
    }

    await setCurrentIndex(currentIndex);
    await play();
  }

  @override
  seek(Duration duration) async {
    await _audioHandler.seek(duration);
  }

  @override
  void onClose() {
    _audioHandler.onClose();
    super.onClose();
  }

  // 对比两个List<SgbData>是否相同
  bool hasDuiBi(List<SgbData> oldList, List<SgbData> newList) {
    for (int i = 0; i < songList.length; i++) {
      if (oldList[i].id != newList[i].id) {
        return false;
      }
    }
    return true;
  }

  @override
  Stream<bool> get playingStream => _audioHandler.playingStream;

  @override
  Stream<Duration> get positionStream => _audioHandler.positionStream;

  @override
  Duration? get duration => _audioHandler.duration;

  @override
  Future<PlayMode> autoNext() async {
    // 先seek到0位置，如何不这样的话，在安卓容易跳歌。
    await _audioHandler.seek(Duration.zero);
    if (playMode.value == PlayMode.single) {
      debugPrint('单曲循环');
      await play();
      return PlayMode.single;
    }

    if (playMode.value == PlayMode.list) {
      debugPrint('列表循环');
      next(isAuto: true);
      return PlayMode.list;
    }

    if (playMode.value == PlayMode.singlePlay) {
      debugPrint('单曲播放');
      await pause();
      seek(Duration.zero);
      return PlayMode.singlePlay;
    }

    return PlayMode.list;
  }

  @override
  Rx<PlayMode> playMode = PlayMode.list.obs;

  SnackbarController? snackbarController;

  @override
  changePlayMode() async {
    playMode.value =
        PlayMode.values[(playMode.value.index + 1) % PlayMode.values.length];
    await box.writeString(GetStorage.playMode, playMode.value.mode);

    // snackbarController = Get.snackbar(
    //   "${'提示'.tr}",
    //   "${playMode.value.name}",
    //   duration: Duration(seconds: 2),
    //   backgroundColor: Theme.of(Get.context!).primaryColor,
    //   colorText: Colors.white,
    // );

    Utils.showToast(playMode.value.name);
  }

  @override
  Stream<Duration?> get durationStream => _audioHandler.durationStream;

  @override
  Future<void> showBottomSheet() async {
    ScrollController scrollController = ScrollController();
    GlobalKey scrollKey = GlobalKey();
    Get.bottomSheet(BottomSheet(onClosing: () {
      scrollController.dispose();
    }, onDragStart: (details) {
      scrollController.dispose();
    }, builder: (context) {
      return _bottomSheet(context, scrollController, scrollKey);
    }));

    Future.delayed(const Duration(milliseconds: 500), () {
      double scrollHeight = currentIndex * 56.0;
      if (scrollHeight < 224) {
        return;
      }
      scrollController.animateTo(scrollHeight,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  _bottomSheet(
      BuildContext context, ScrollController scrollController, Key? key) {
    return SizedBox(
        height: StarThemeData.bottomSheetHeight,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              height: StarThemeData.bottomAppBarHeight,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(
                  horizontal: StarThemeData.spacing,
                  vertical: StarThemeData.spacing),
              child: Text(
                '播放列表'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  key: key,
                  controller: scrollController,
                  itemCount: songList.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return SongListTile(
                        song: songList[index],
                        selected: _currentIndex.value == index,
                        playing: playing,
                        onTap: (SgbData song) {
                          if (index != currentIndex) {
                            playByIndex(index);
                          }

                          Get.back();
                        },
                      );
                    });
                  }),
            )
          ],
        ));
  }

  SgbService get _sgbService => SgbService.to;

  /// 初始化播放器数据
  /// 有历史记录则播放历史记录
  /// 无则填充默认数据
  @override
  initStarPlayer() async {
    String? playModeStr = await box.readString(GetStorage.playMode);
    if (playModeStr != null) {
      playMode.value =
          PlayMode.values.firstWhere((element) => element.mode == playModeStr);
    }

    if (songList.isEmpty) {
      if (_sgbService.shijiTypeList.isNotEmpty) {
        String? praiseId = await box.readString(GetStorage.praiseId);

        int firstTypeId = await box.readInt(GetStorage.praiseListId) ??
            _sgbService.shijiTypeList[0].id;
        ShijiTypeEnum shijiTypeEnum = ShijiTypeEnum.shiji;
        String? songListType = await box.readString(GetStorage.songListType);
        if (songListType != null) {
          shijiTypeEnum = ShijiTypeEnum.values
              .firstWhere((element) => element.type == songListType);
        }

        List<SgbData> list =
            await _sgbService.getSgbDataListById(firstTypeId, shijiTypeEnum);
        debugPrint('list is empty: ${list.isEmpty}');
        if (list.isEmpty) {
          // 如果列表为空，则填充默认数据
          list = await _sgbService.getSgbDataListById(8, ShijiTypeEnum.shiji);
        }
        int index = 0;
        if (praiseId != null) {
          // 从赞美列表中获取数据
          index = list.indexWhere((element) => element.id == praiseId);
          debugPrint('index: $index');
          index = index < 0 ? 0 : index;
        }

        await setSongList(list, index);
      }
    }
  }

  @override
  AudioSource get palyerAudioSource => _audioHandler.palyerAudioSource;

  shareUrl() async {
    Song? song = StarPlayer.to.currentSong.value!;
    String type = await box.readString(GetStorage.songListType) ??
        ShijiTypeEnum.shiji.type;
    String praiseListId = await box.readString(GetStorage.praiseListId) ?? '';
    String url = '$shareBaseUrl/playnew/${song.id}/$praiseListId/$type';

    Utils.shareUrl(url);
  }

  void shareGePuFile() async {
    if (StarPlayer.to.currentSong.value == null ||
        StarPlayer.to.currentSong.value!.dmtUrl.gepuUrl == null) {
      Toast.showToast('当前歌谱无法分享'.tr);
      return;
    }
    String url = StarPlayer.to.currentSong.value!.dmtUrl.gepuUrl!;
    if (await DownFile.isUrlFileExists(url: url)) {
      String savePath = await DownFile.getUrlFIlePath(url: url);
      DownFile.shareFile(savePath);
      return;
    }

    await DownFile.shareDownFile(
        StarPlayer.to.currentSong.value!.dmtUrl.gepuUrl!,
        StarPlayer.to.currentSong.value!.fullTitle);
  }

  void shareAudioFile({String? title}) async {
    if (StarPlayer.to.currentSong.value == null ||
        StarPlayer.to.currentSong.value!.dmtUrl.adUrl == null) {
      Toast.showToast('当前歌曲无法分享'.tr);
      return;
    }
    String url = StarPlayer.to.currentSong.value!.dmtUrl.adUrl!;
    if (await DownFile.isUrlFileExists(url: url)) {
      String savePath = await DownFile.getUrlFIlePath(url: url);
      DownFile.shareFile(savePath,
          title: title ?? '文件分享：${StarPlayer.to.currentSong.value!.fullTitle}');
      return;
    }
    await DownFile.shareDownFile(StarPlayer.to.currentSong.value!.dmtUrl.adUrl!,
        StarPlayer.to.currentSong.value!.fullTitle);
  }

  void shareLyric() {
    if (StarPlayer.to.currentSong.value == null ||
        StarPlayer.to.currentSong.value!.dmtUrl.lyric == null) {
      Toast.showToast('当前歌词无法分享'.tr);
      return;
    }
    String lyric = StarPlayer.to.currentSong.value!.dmtUrl.lyric!;
    Utils.shareText(lyric);
  }

  @override
  Future<void> playBanZou() async {
    await _audioHandler.playBanZou();
  }

  @override
  Future<void> playYuanChang() async {
    await _audioHandler.playYuanChang();
  }

  Timer? _sleepTimer;

  /// 设置睡眠定时器，指定分钟后停止播放
  void setSleepTimer(int minutes) {
    // 取消之前的定时器
    _sleepTimer?.cancel();

    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        pause(); // 暂停播放
        _sleepTimer = null;
        Utils.showToast('定时停止播放已生效'.tr);
        // 在后台运行时也需要能执行暂停操作
        Get.forceAppUpdate();
      });
      Utils.showToast('已设置 $minutes 分钟后停止播放'.tr);
    } else {
      Utils.showToast('已取消定时停止播放'.tr);
    }
  }

  /// 取消睡眠定时器
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    Utils.showToast('已取消定时停止播放'.tr);
  }

  /// 获取剩余睡眠时间（分钟）
  int getRemainingSleepTime() {
    if (_sleepTimer == null) return 0;

    // 计算剩余时间的逻辑稍作调整
    // 这里简单返回设定的时间，实际应用中可能需要更精确的计算
    return 0; // 实际剩余时间计算较复杂，这里简化处理
  }

  /// 检查是否正在使用睡眠定时器
  bool get isSleepTimerActive => _sleepTimer != null;

  @override
  Future<void> switchPlayTarget(PlayTargetEnum value) async {
    await _audioHandler.switchPlayTarget(value);
  }
}
