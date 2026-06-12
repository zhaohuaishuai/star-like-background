import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/user.dart';
import 'package:m/data/module/user_song.dart';
import 'package:m/data/module/user_song_detail.dart';
import 'package:m/data/services/sgb.dart';
import 'package:m/data/services/user.dart';

abstract class GeDanListControllerAbs extends GetxController {
  UserProvider api = Get.put<UserProvider>(UserProvider());
  Rx<UserSong?> song = Rx<UserSong?>(null);
  Rx<bool> loading = false.obs;
  List<UserSongDetail?> get list { 
    if (song.value == null) return []; 
    return SgbService.to.getUserSongDetailList(song.value?.list);
  }

  Future<UserSong?> getDataSource();

  /// 当前设备指纹ID（在 onInit 中缓存）
  String? _deviceFingerprintId;

  /// 权限按钮has
  bool get hasPer {
    // 已登录且是本人的歌单
    if (UserService.to.isLogin &&
        song.value?.userId == UserService.to.user?.userId) {
      return true;
    }
    // 未登录但歌单属于当前设备指纹
    if (!UserService.to.isLogin &&
        song.value?.userId == null &&
        song.value?.fingerprintId != null) {
      return true;
    }
    // 已登录但歌单是指纹歌单（userId 为 null），检查指纹是否匹配
    if (UserService.to.isLogin &&
        song.value?.userId == null &&
        song.value?.fingerprintId != null &&
        song.value?.fingerprintId == _deviceFingerprintId) {
      return true;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('gedanlist page init');
    _cacheFingerprintId();
    init();
  }

  Future<void> _cacheFingerprintId() async {
    _deviceFingerprintId = await UserService.to.getFingerprintId();
  }

  Future<void> init() async {
    // if (!UserService.to.isLogin) {
    //   return;
    // }
    loading.value = true;

    song.value =
        await getDataSource(); //await SgbService.to.getSongListDetail(id);

    loading.value = false;
  }

  toPlayer(UserSongDetail? list) {
    if (list == null) return;
    if (list.type == GeDanListType.geDan) {
      RouterUtils.toPlayer(list.id, song.value!.id,
          shijiTypeEnum: ShijiTypeEnum.gedan);
    }

    if (list.type == GeDanListType.jw) {
      // Utils.showToast("经文暂时不支持".tr);
      Get.toNamed(AppRoutes.jingwengres,arguments: {'id':list.id});
    }
    // RouterUtils.toPlayer(list.id, list.shijiId,
    //     toPathCallback: (path) => Get.offAndToNamed(path));
  }

  shareUrl() {
    Utils.shareUrl('$shareBaseUrl/gedanlist/${song.value?.id}');
  }

  addItem() async {
    bool success = await UserService.to.addSongListItemToSearch(song.value?.id);
    if (success) {
      refresh();
    }
  }

  delItem(String id) async {
    bool success =
        await UserService.to.delSongListItemDIalog(song.value?.id, id);
    if (success) {
      refresh();
    }
  }

  @override
  Future<void> refresh() async {
    song.value =
        await getDataSource(); //await SgbService.to.getSongListDetail("${song.value?.id}");
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    debugPrint('oldIndex:$oldIndex,newIndex:$newIndex');
    List<UserSongDetail?> list = [...this.list];
    var temp = list.removeAt(oldIndex);
    list.insert(newIndex, temp);
    debugPrint('strList:${list.length}');
    List<String> newList =
        list.map((e) => '${e?.id}|${e?.type.index}').toList();
    String strList = newList.join(',');
    debugPrint('strList:$strList');
    song.value = song.value!.copyWith(list: strList);
    UserService.to.updateSongList(id: song.value!.id, list: strList);
  }


  Future<void> copyId() async {
    await Utils.copyText(song.value!.id.toString());
    Utils.showToast('复制成功 ID:${song.value!.id}'.tr);
  }
}

class GeDanListController extends GeDanListControllerAbs {
  @override
  Future<UserSong?> getDataSource() async {
    var id = Get.parameters['id'];
    debugPrint('id:$id');
  
    return await SgbService.to.getSongListDetail(id ?? '${song.value!.id}');
  }
}
