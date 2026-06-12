import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import "package:get/get.dart";
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import '../api/api.dart';
import '../type/sgbType.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../storage/sgbStorage.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import '../utils/downUtils.dart';
import 'package:dio/dio.dart';

class SgbContainer extends GetxController {
  final sgbStorage = SgbStorage();
  final storage = GetStorage();
  final SgbProvider api = SgbProvider();
  // 版本
  final version = ''.obs;
  RxString versionContext = ''.obs;
  // 是否展示弹窗
  final RxBool versionShowDialog = false.obs;
  // 当前激活的诗集类型，用于列表展示的
  RxInt activeIndex = 0.obs;
  // 当前播放列表的诗集类型，用于播放器的
  RxInt playListActiveIndex = 0.obs;
  // 诗集类型
  final sgbdb = Rx<List<SgbDb>>([]);
  // 全部赞美的列表
  final sgb = Rx<List<SgbData>>([]);

  // 当前选中的赞美列表
  final currendList = Rx<List<SgbData>>([]);
  // 当前选中的诗集的名称
  RxString activeShiJiName = ''.obs;
  // 播放器的实例
  final player = AudioPlayer().obs;
  // 播放列表
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(useLazyPreparation: false, children: []);
  var listenPlayerTagId = '';
  // 列表排序
  RxBool sorted = false.obs;
  // 上一个列表排序的值
  RxBool preSorted = false.obs;
  // 程序初始化loading开关
  RxBool initLoading = false.obs;

  // 呼吸音频
  audio.AudioPlayer huxiAudioPlayer = new audio.AudioPlayer();


  List<SgbDb> get originalTypeSgbDb {
    return sgbdb.value.where((element){
      return element.type == SgbTypeEnum.original_type;
    }).toList();
  }

  @override
  void onInit() async {
    print("初始化数据");
    super.onInit();
    appInit();
  }


  appInit() async {

    initLoading.value = true;
    // sgbStorage.storage.erase();
    api.baseUrl = api.basePath;
    print("api.basePath-->${api.basePath}");
    // 加载版本
    try {
      Version version = await api.getVersion();
      if (sgbStorage.version != version.version && version.version != null) {
        print("更新版本了");
        await sgbStorage.removeSgbAll();
        sgbStorage.version = version.version as String;
      };
    }catch(err){
      print("更新报错"+ err.toString());
    } finally {
      initLoading.value = false;
    }

     // 加载全部诗集
    var sgbRes = await api.getSgb(1, 1000);
    var a = sgbRes.body["rows"];
    sgb.value = a.map((e) {
        return SgbData.fromJson(e);
      },
    ).toList().cast<SgbData>();



    // 加载诗集类型
    var shijiRes = await api.getShiji();

    if (shijiRes.bodyString != null && shijiRes.body["code"]==200) {
        var a = shijiRes.body['rows'];
        var b = a.map((item) {
              List sgbList = sgb.value.where((element) {
                return element.shiji_index == item['id'];
              }).toList();
              item['list'] = sgbList;
              return SgbDb.fromJson(item);
            }).toList().cast<SgbDb>();
            sgbdb.value = b as List<SgbDb>;
    } else {
      try {
        // 数据未加载成功，加载本地数据。
        var sgbDataJson = await rootBundle.loadString('lib/json/sgbdb.json');
        sgbdb.value = json
            .decode(sgbDataJson)
            .map((item) {
          return SgbDb.fromJson(item);
        }).toList().cast<SgbDb>();
      } catch (err) {
        print("json加载错误$err");
      }
    }

    // 根据上次保存的诗集类型，更新诗集列表

    activeIndex.value = sgbStorage.activeIndex ?? 0;
    print("查看上一次的诗集类型");
    print("sgbStorage.activeIndex==${sgbStorage.activeIndex}");
    updateSgb(activeIndex.value);
    // 更新just_audio的列表
    await updatePlayList(currendList.value);
    // 监听诗集类型变化来更新列表
    activeIndex.listen((p0) {
      print("监听诗集类型变化来更新列表${p0}");
      sgbStorage.activeIndex = activeIndex.value;
      updateSgb(p0);
    });
    // 当前激活播放的诗集存储到本地
    playListActiveIndex.listen((p0) {
      print("当前激活播放的诗集存储到本地${p0}");
      sgbStorage.activeIndex = activeIndex.value;
    });
    // 设置播放列表
    await player.value.setAudioSource(playlist,
        preload: true,
        initialIndex: sgbStorage.playInitialIndex == null
            ? 0
            : sgbStorage.playInitialIndex.toInt());
    // 初始化
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // // Listen to errors during playback.
    player.value.playbackEventStream.listen(
      (event) {

      },
      onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      }
    );
    player.value.currentIndexStream.listen((event) {
      print("切换当前的index$event");
      sgbStorage.playInitialIndex = event;
      downStarFile();
    });
    // 设置单曲循环会有问题
    // await player.value.setLoopMode(LoopMode.one);
    // player.value.setLoopMode(sgbStorage.loopMode);
    // player.value.loopModeStream.listen((val) {
    //   print("播放模式$val");
    //   sgbStorage.loopMode = val;
    // });

    // // 排序变化监听  web端监听无效，注释掉
    // sorted.listen((p0) {
    //   // 记忆一下上一次的排序状态
    //   preSorted.value = !p0;
    //   sortPlayList(p0);
    // });


  }
  // 根据id查看赞美的数据
  SgbData queryById(String id) {
    return sgb.value.firstWhere((element) {
      return element.id == id;
    });
  }
  // 根据id查看赞美类型的数据
  SgbDb queryByIdSgbdb(int id) {
    return sgbdb.value.firstWhere((element) {
      return element.id == id;
    });
  }

  /**
   * 根据di查看当前播放列表中的赞美的索引值
   */
  int querySgbDataIdtoIndex(String id){
    return currendList.value.indexWhere((element) => element.id == id);
  }

  void updateSgb(index) {
    print("诗集列表更新$index");
    sgbStorage.activeIndex = index;
    currendList.value = sgb.value.where((element) => element.shiji_index == index).toList();
    sortPlayList(sorted.value);
  }

  void updateActiveIndex(index) {
    activeIndex.value = index;
  }

  // 更新just_audio的播放列表
  updatePlayList(List<SgbData> data) async {
    // 当前播放的歌单不是现播放列表的歌单时，如果播放器，在播放音乐，需要停止。在切列表，否则会报错
    await player.value.stop();
    var list = await transitionPlayList(data);
    if (playlist.length > 0) {
      await playlist.clear();
    }
    await playlist.addAll(list);
    playListActiveIndex.value = activeIndex.value;
    return true;
  }

  String? getShijiTypeName(int shijiIndex) {
    return sgbdb.value.firstWhereOrNull((element) => element.id == shijiIndex)?.name;
  }
   Future<List<AudioSource>> transitionPlayList(List<SgbData> list) async  {
    bool isGranted =  await downPer.isGranted();
    final List<AudioSource> reslist = [];
    var dirPath = await downPer.downloadsPath + '/star/mp3/';
    List<String> mp3Paths = await downPer.getDirFilesPath(dirPath);
    RegExp regExp = RegExp(r'[/\\]');
    List<String> fileNames = mp3Paths.map((path)=>path.split(regExp).toList().last).toList();
    for(int i = 0 ;i < list.length; i++){
      final UriAudioSource audioSource ;
      SgbData e = list[i];
      var mp3Name = '${e.shiji_index}_${e.full_title}.mp3';
      var index = fileNames.indexOf(mp3Name);
      // 文件即存在，又获取到了访问外部存储的权限
      if(index != -1){
        audioSource = AudioSource.uri(Uri.file(mp3Paths[index]));
      } else{
        audioSource = AudioSource.uri(Uri.parse(e.dmturl.adUrl ?? 'https://123.mp3'));
      }

      reslist.add(
        ClippingAudioSource(
          child: audioSource,
          tag: MediaItem(
            id: e.id.toString(),
            //充当序号
            album: e.xuhao.toString(),
            title: e.full_title.toString(),
            // 所属诗集或歌单
            displayTitle: "${e.full_title}",
            displaySubtitle: getShijiTypeName(e.shiji_index) ?? '',
            artUri: Uri.parse("https://oss.top237.top/img/star_web_bg_820.jpg"),
          ),
        )
      );
    }
    return reslist;
  }

  // 把AudioSource类型转换成Sgbdb
  List<SgbData> transitionSgbDataList(List<IndexedAudioSource> list) {
    return list.map((element) {
      var val = sgb.value.firstWhere((ele) {
        return ele.id == element.tag.id;
      });
      return val;
    }).toList();
  }

  // 更新播放历史日志
  updateHistory(PlayerState event) {

    if (event.playing) {
      // print("插入历史记录0");
      var id = player.value.sequenceState!.currentSource!.tag.id;
      if (id != listenPlayerTagId) {
        SgbData data = queryById(id);
        // 分析埋点
        MatomoTracker.instance.trackEvent(
            eventCategory: 'play', action: "${data.title}", eventName: data.id);
        // print("插入历史记录1");

        sgbStorage.history = id;
        listenPlayerTagId = id;
      }
    }
  }

  // 大列表跳转播放页面
  Future<bool> toPlayPage(SgbData item, int index, bool isCurPlayList) async {
    print("大列表跳转：${index}");
    var prevPlaying = player.value.playing;
    // 当前选择的诗集歌单，不是当前的显示列表的歌单时
    if (!isCurPlayList || (preSorted != sorted.value)) {
      await updatePlayList(currendList.value);
      isCurPlayList = true;
      preSorted.value = sorted.value;
    }
    await Future.delayed(Duration.zero);
    var id = item.id.toString();
    var preId = null;
    if(player.value.sequenceState!=null && player.value.sequenceState!.currentSource !=null){
      preId = player.value.sequenceState!.currentSource!.tag!.id.toString();
    }
    if (id != preId) {
      try {
        if (prevPlaying && isCurPlayList) {
          // print("是当前列表且需要停止的状态下");
          await player.value.stop();
        }
        await player.value.seek(Duration.zero, index: index);
        // print("切换歌曲");
        if (prevPlaying) {
          await Future.delayed(Duration.zero);
          await player.value.play();
          // print("等待一下");
        }
      } catch (err) {
        print("切换歌曲发生错误${err.toString()}");
        throw "发生了错误";
      }
    }
    Get.toNamed(RouteName.playerPage.value);
    return isCurPlayList;
  }

  // 列表排序
  sortPlayList(bool desc) {
    var list = currendList.value.map((e) => e).toList();
    if (desc) {
      list.sort((SgbData a, SgbData b) {
        return a.xuhao - b.xuhao;
      });
    } else {
      list.sort((SgbData a, SgbData b) {
        return b.xuhao - a.xuhao;
      });
    }
    // list.map((e) {
    //   print(e.xuhao);
    // });
    currendList.value = list;
  }

  // 歌单类型的列表去到playerPage面的逻辑
  Future<void> songLostToPlayerPage(
    bool isUpdateHistoryList,
    SgbData data,
    int index,
    List<SgbData> historyList,
    VoidCallback routeCallBack,
  ) async {
    var prevPlaying = player.value.playing;
    var id = data.id.toString();
    var preId = player.value.sequenceState!.currentSource!.tag!.id.toString();
    if (id != preId) {
      if (!isUpdateHistoryList) {
        await updatePlayList(historyList);
        isUpdateHistoryList = true;
      }
      await Future.delayed(Duration.zero);
      await player.value.seek(Duration.zero, index: index);
      // print("当前的音频信息${data.full_title}");
      // print("当前的音频信息${data.shiji_index}");
      sgbStorage.activeIndex = data.shiji_index;

      // await sgbContainer.player.value.load();
      if (prevPlaying) {
        player.value.play();
      }
    }
    Get.toNamed(RouteName.playerPage.value)!.then((_) => routeCallBack());
  }

  // 为了适配微信浏览器，使用原生just_audio方法，线上报错的bug。独立封装的方法
  Future<void> seekToNext() async {
    if (player.value.hasNext) {
      var prePlaying = player.value.playing;
      if (prePlaying) {
        await player.value.stop();
        await Future.delayed(Duration.zero);
      }
      await player.value.seekToNext();

      if (prePlaying) {
        player.value.play();
      }
    }
  }

  Future<void> seek(int index) async {
    if (index != player.value.currentIndex) {
      var prePlaying = player.value.playing;
      if (prePlaying) {
        await player.value.stop();
        await Future.delayed(Duration.zero);
      }
      await player.value.seek(Duration.zero, index: index);
      if (prePlaying) {
        player.value.play();
      }
    }
  }

  Future<void> seekToPrevious() async {
    if (player.value.hasPrevious) {
      var prePlaying = player.value.playing;
      if (prePlaying) {
        await player.value.stop();
        await Future.delayed(Duration.zero);
      }
      await player.value.seekToPrevious();
      if (prePlaying) {
        player.value.play();
      }
    }
  }


  /**
   * 下载文件到本地缓存起来
   */
  Future<void> downStarFile({String? fileType = 'mp3', void Function(int count, int total,int progress)? onReceiveProgress}) async{
    var list = transitionSgbDataList(player.value.sequence??[]);
    SgbData e = list[player.value.currentIndex as int];
    bool isGranted =  await downPer.isGranted();
    var mp3Path =  await downPer.getSavePath(e.dmturl.adUrl ?? 'https://123.mp3', 'star/${fileType}/${e.shiji_index}_${e.full_title}');
    // 检查这个文件是否被缓存到本地了。
    bool isExist = await downPer.testFile(mp3Path);
    // 后台上传文件逻辑更换，不用检查md5了
    if(isExist){
       String md5 = await downFile.filemd5(mp3Path);
       Dio dio = Dio();
       var md5Res = await dio.get(api.basePath + '/start/shijidb/md5?url=' + e.dmturl.adUrl);
       if(md5Res.statusCode == 200 && md5Res.data['code'] == 200){
         String remoteMd5 = md5Res.data['msg'];
         print("👉远程md5：$remoteMd5 \n 👉本地的md5: $md5");
         if(md5 != remoteMd5){
           isExist = false;
         }
       }
    }
    print("下载有检查文件：名称：${e.full_title}\n远程链接：${e.dmturl.adUrl}，\n权限是否打开： $isGranted,\n是否存在：${isExist}");
    if(!isExist){
      Dio dio = Dio();
      int progress = 0;
      await dio.download(e.dmturl.adUrl, mp3Path, onReceiveProgress: (count,total) async {
        progress = (count/total*100).floor();
        // print("下载进度：${progress}");
        if(progress == 100){
          print("${e.full_title}，下载完成");
        }
        if (onReceiveProgress !=null){
          onReceiveProgress(count,total,progress);
        }
      });
    }
  }
  /**
   * 定时关闭功能
   */
  final isTimingRun = Rx<bool>(false);
  final timer =  Rx<Timer>(Timer(Duration(seconds: 0),(){})); // 用于管理计时器
  final periodicTimer =Rx<Timer>(Timer(Duration(seconds: 0),(){}));
  final startTime = Rx<DateTime>(DateTime.now());
  final _duration = Rx<Duration>(Duration(seconds: 0));
  Rx<String> diffDuration = "".obs ;
  void startTimer(Duration duration) {
    timer.value.cancel(); // 取消任何正在进行的计时器
    periodicTimer.value.cancel();
    startTime.value = DateTime.now();
    _duration.value = duration;
    isTimingRun.value = true;
    timer.value = Timer(duration, () async{
      // 这里设置你希望在定时后执行的功能，比如停止音乐
      // 停止音乐播放的代码逻辑
      if(player.value.playing){
        await player.value.pause();
      }
      periodicTimer.value.cancel();
      isTimingRun.value = false;
      diffDuration.value = "";
    });
    periodicTimer.value = Timer.periodic(Duration(seconds: 1), (timer) {
      diffDuration.value = formatDuration(getRemainingTime());
    });
  }
  Duration getRemainingTime() {
    final elapsed = DateTime.now().difference(startTime.value);
    return _duration.value - elapsed;
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  cancelTimer(){
    timer.value.cancel(); // 取消任何正在进行的计时器
    periodicTimer.value.cancel();
    isTimingRun.value = false;
    diffDuration.value = "";
  }

}





class SgbContainerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SgbContainer>(SgbContainer());
  }
}
