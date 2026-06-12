 
import 'package:flutter/cupertino.dart';
 
import 'package:get/get.dart';

 
import 'package:m/core/utils/utils.dart';
import 'package:m/data/module/sgb_data.dart';
 
import 'package:m/data/services/sgb.dart';
import 'package:m/data/services/star_player.dart';
import 'package:photo_view/photo_view.dart';

class PlayNewController extends FullLifeCycleController with FullLifeCycleMixin {
  final count = 0.obs;
  PageController lyricController = PageController(initialPage: 1);
  RxInt currentLyricIndex = 1.obs;
  RxBool isPlaying = false.obs;
  RxDouble currentDuration = 0.0.obs;
  Rx<PhotoViewScaleState> scaleState = Rx<PhotoViewScaleState>(PhotoViewScaleState.initial);


 
  ScrollPhysics? get physics {

    if(scaleState.value == PhotoViewScaleState.zoomedIn && currentLyricIndex.value == 0){
      return const NeverScrollableScrollPhysics();
    }
    return null;


  }
  final RxBool _pageHide = false.obs;
  bool get pageHide => _pageHide.value;
  String? songId = Get.parameters['id'];
  String? songType = Get.parameters['type'];
  String? songGedanId = Get.parameters['gedanid'];

  String? get lrc => StarPlayer.to.currentSong.value?.dmtUrl.lrc;
  String? get lyric => StarPlayer.to.currentSong.value?.dmtUrl.lyric;
  String? get gepuUrl => StarPlayer.to.currentSong.value?.dmtUrl.gepuUrl;
  String? get assLyric => StarPlayer.to.currentSong.value?.dmtUrl.assLyric;


  GetStorage box = GetStorage();

  RxBool breathe = false.obs;

  @override
  void onInit() async {
    super.onInit();

  
    debugPrint("id: ${Get.parameters['id']}");
    debugPrint("type: ${Get.parameters['type']}");
    debugPrint("gedanid: ${Get.parameters['gedanid']}");
    // assert(Get.parameters['id'] != null);

    if (Get.parameters['id'] == null) {
      return;
    }

    ShijiTypeEnum? type = ShijiTypeEnum.shiji;
    for (ShijiTypeEnum item in ShijiTypeEnum.values) {
      if (item.type == Get.parameters['type']!) {
        type = item;
        break;
      }
    }
    List<SgbData> sgbDataList = await SgbService.to
        .getSgbDataListById(int.parse(Get.parameters['gedanid']!), type!);

    debugPrint('sgbDataList: ${sgbDataList.length}');

    int index =
        sgbDataList.indexWhere((item) => item.id == Get.parameters['id']!);
    debugPrint('index: $index');
    if (index == -1) {
      return;
    }
    await StarPlayer.to.setSongList(sgbDataList, index);
     
    if(StarPlayer.to.playing){
        await StarPlayer.to.play();
    }

   

    
   
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('onReady');
  }
 
  changePage(int value) {
    currentLyricIndex.value = value;
  }

  shareUrl() async {
      StarPlayer.to.shareUrl();
  }

  void shareGePuFile() async {
    StarPlayer.to.shareGePuFile();
  }

  void shareAudioFile() async {
      StarPlayer.to.shareAudioFile();
  }


  void shareLyric() {
      StarPlayer.to.shareLyric();
  }
  
  @override
  void onDetached() {
     
    debugPrint('onDetached 后台');
  }
  
  @override
  void onHidden() {
     
    debugPrint('onHidden 隐藏');
  }
  
  @override
  void onInactive() {
     
    debugPrint('onInactive 后台');
    _pageHide.value = true;
  }
  
  @override
  void onPaused() {
  
    debugPrint('onPaused 暂停');
  }
  
  @override
  void onResumed() {
    
    debugPrint('onResumed 恢复前台');
    _pageHide.value = false;
  }


}
