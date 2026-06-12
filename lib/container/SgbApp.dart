

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import '../api/api.dart';
import '../type/sgbType.dart';
import 'package:flutter/src/services/asset_bundle.dart';
import 'dart:convert';

abstract class StarAudioImp {
  /**
   * 播放
   */
  Future<bool> starPlay(SgbData data);
}
class StarAudioPlayer extends AudioPlayer implements StarAudioImp {
  @override
  Future<bool> starPlay(SgbData e) async {
    UriAudioSource audioSource = AudioSource.uri(Uri.parse(e.dmturl.adUrl));
    ClippingAudioSource clippingAudioSource = ClippingAudioSource(
      child: audioSource,
      tag: MediaItem(
        id: e.id.toString(),
        title: e.full_title.toString(),
        displayTitle: "${e.full_title}",
        artUri: Uri.parse("https://star.top237.top/lsky/heng-ping.jpg"),
      ),
    );

    this.setAudioSource(clippingAudioSource);
    await this.play();
    return true;
  }
}

class SgbApp extends GetxController {

  final api = Get.find<SgbProvider>();

  final sgbType = Rx<List<SgbDb>>([SgbDb(name:'附录',id:0,isUpper: true,list:[])]);

  final sgbDataList = Rx<List<SgbData>>([]);

  final initLoading = false.obs;

  final StarAudioPlayer starAudioPlayer= StarAudioPlayer();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async{
    await getSgbDataList();
    await getShijiType();
  }

  Future<bool> getShijiType() async {
    var shijiRes = await api.getShiji();
    if (shijiRes.bodyString != null && shijiRes.body["code"]==200) {
      var a = shijiRes.body['rows'];
      List<SgbDb> b = a
          .map((item) {
        List sgbList = sgbDataList.value.where((element) => element.shiji_index == item['id']).toList();
        item['list'] = sgbList;
        return SgbDb.fromJson(item);
      })
      .toList()
      .cast<SgbDb>();
      sgbType.value = b ;
      return true;
    }
    return false;
  }

  getSgbDataList() async {
    // 加载全部诗集
    var sgbRes = await api.getSgb(1, 1000);
    initLoading.value = false;
    if (sgbRes.body != null && sgbRes.body["code"] == 200) {
      var a = sgbRes.body["rows"];
      sgbDataList.value = a.map((e) {
        return SgbData.fromJson(e);
      },
      ).toList().cast<SgbData>();
      
    } else {
      try {
        // 网络连接不成功，加载本地数据
        var sgbDataJson = await rootBundle.loadString('lib/json/sgb.json');
        sgbDataList.value = json
            .decode(sgbDataJson)
            .map((item) {
          return SgbData.fromJson(item);
        }).toList().cast<SgbData>();
      } catch (err) {
        print("json加载错误$err");
      }
    }
  }

  play(SgbData e) async {
    await starAudioPlayer.starPlay(e);
  }

  @override
  void onClose() {
    super.onClose();
  }

}



class SgbAppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SgbProvider>(SgbProvider());
    Get.put<SgbApp>(SgbApp());
  }
}
