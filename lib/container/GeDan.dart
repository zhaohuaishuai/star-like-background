import 'package:flutter/cupertino.dart';
import '../storage/sgbStorage.dart';
import '../type/sgbType.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import '../utils/utils.dart';
import '../container/sgbContainer.dart';
class GeDanController extends GetxController {
  SgbStorage storage = SgbStorage();
  SgbContainer sgbController = Get.find<SgbContainer>();
  final historyList = Rx<List<SgbData>>([]);
  final songList =Rx<List<SongListData>>([]);
  Rx<SongListData>? currentSongData = Rx<SongListData>(SongListData());
  Rx<String> currentSongId = ''.obs ;
  @override
  void onInit() async {
    updateSongList();
    currentSongId.listen((p0) {
      updateSongList();
    });
    super.onInit();
  }
  void updateSongList(){
    songList.value = storage.songList;
    print("currentSongId.value${currentSongId.value}");
    if(currentSongId.value != ''){
      currentSongData?.value = getCurrentSongData();
      historyList.value = getSgbDataList();
    }
  }

  deleteSongList(SongListData data,int index){
    if(data.id.toString() == currentSongId.value){
      currentSongId.value = '';
    }
    storage.delSongList(data.id.toString());
    updateSongList();
  }

  void submit(
      {
        String? title,
        GlobalKey<FormState>? formKey,
        String? createdAt,
        String? updatedAt,
        String? id,
        String? ids,
      }
  ) async {
    var userId = await Jutils.deviceDetails();
    if (formKey != null && formKey.currentState!.validate()) {
      var data = SongListData(
        id: id ?? Uuid().v4(),
        title: title,
        isPut: false,
        createdAt: createdAt??DateTime.now().toString(),
        updatedAt: updatedAt??DateTime.now().toString(),
        userId: userId,
        ids:ids,
      );
      storage.addSongList(data);
      updateSongList();
      Get.back();
    }
  }

  bool addList(String id){

    print("id-->${id}");
    var ids = currentSongData?.value.ids??'';

    if(ids.indexOf(id)!=-1){
      return false;
    }

    if(id != ''){
      ids += ',' + id;
    }
    var data = SongListData(
      id: currentSongId.value,
      title: currentSongData?.value.title,
      isPut: false,
      createdAt: currentSongData?.value.createdAt,
      updatedAt: DateTime.now().toString(),
      userId: currentSongData?.value.userId,
      ids:ids,
    );
    storage.addSongList(data);
    updateSongList();
    return true;
  }

  SongListData getSongData(String id){
    return storage.getSongData(id);
  }
  SongListData getCurrentSongData() {
    print("currentSongId ${currentSongId.value}");
    return getSongData(currentSongId.value);
  }

   List<SgbData>  getSgbDataList() {
    if(currentSongData?.value.ids == null){
      return [];
    }
    List<String>? idsList = currentSongData?.value.ids?.split(",").toList();
    if(idsList == null || idsList.length == 0){
      return [];
    }
    return idsList.where((element) => element!='').map((String id) {
      return sgbController.sgb.value.firstWhere((SgbData element) => element.id == id);
    }).toList();
  }

  deleteSgbData(String id) {
    List<SgbData> newHistoryList = historyList.value.where((element) => element.id != id).toList();
    List<String> newIds = newHistoryList.map((element)=>element.id).toList();
    String ids = newIds.join(',');
    var data = SongListData(
      id: currentSongId.value,
      title: currentSongData?.value.title,
      isPut: false,
      createdAt: currentSongData?.value.createdAt,
      updatedAt: DateTime.now().toString(),
      userId: currentSongData?.value.userId,
      ids:ids,
    );
    storage.addSongList(data);
    updateSongList();

  }


}


class GeDanBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<GeDanController>(GeDanController());
  }
}
