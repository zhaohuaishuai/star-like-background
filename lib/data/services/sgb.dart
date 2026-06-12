import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/sgb.dart';
import 'package:m/data/api/user.dart';

import 'package:m/data/module/sgb_data.dart';
import 'package:m/data/module/shiji_type.dart';
import 'package:m/data/module/user_song.dart';
import 'package:m/data/module/user_song_detail.dart';
import 'package:m/data/services/star_player.dart';

enum ShijiTypeEnum {
  shiji('shiji'),
  gedan('gedan');

  final String type;
  const ShijiTypeEnum(this.type);
}

class SgbService extends GetxService {
  final api = Get.put<SgbProvider>(SgbProvider());
  final UserProvider userApi = Get.put<UserProvider>(UserProvider());
  final GetStorage box = GetStorage();
  String oldVersion = '';
  bool _isUpdate = false;
  Rx<bool> loading = true.obs;
  final RxList<SgbData> _sgbDataList = RxList<SgbData>([]);
  List<SgbData> get sgbDataList => _sgbDataList;
  final RxList<ShijiType> _shijiTypeList = RxList<ShijiType>([]);
  List<ShijiType> get shijiTypeList => _shijiTypeList;
  static SgbService get to => Get.find();
  RxBool isDesc = true.obs;

  Future<SgbService> init() async {
    loadData();
    return this;
  }

  loadData() async {
    loading.value = false;

    try {
      await initVersion();
      await initSgbData();
      StarPlayer.to.initStarPlayer();
    } catch (e) {
      Toast.showToast('初始化失败${e.toString()}');
      debugPrint('初始化失败${e.toString()}');
      e.printInfo();
    } finally {
      loading.value = false;
    }

    try {
      isDesc.value = await box.readBool(GetStorage.sort) ?? true;
    } catch (e) {
      debugPrint('获取排序状态报错：${e.toString()} ${e.runtimeType}');
    }
  }

  initVersion() async {
    try {
      oldVersion = await box.readString(GetStorage.version) ?? '';
    } catch (e) {
      debugPrint('初始化版本号失败${e.toString()}');
    }

    String version = await api.getVersion();
    debugPrint('旧版本号$oldVersion,新版本号：$version');
    try {
      await box.writeString(GetStorage.version, version);
    } catch (e) {
      debugPrint('写入版本号失败${e.toString()}');
    }
    _isUpdate = version != oldVersion;
    await _clearStorage();
  }

  Future<void> _clearStorage() async {
    debugPrint('isUpdate:$_isUpdate');
    if (_isUpdate) {
      await clearVisionStorage();
    }
  }

  Future<void> clearVisionStorage() async {
    Map<String, dynamic> allStorage = await box.readAllKey();
    for (var key in allStorage.keys) {
      String cacheKey = '${GetStorage.version}$cacheSplit';
      bool withVersion = key.startsWith(cacheKey);
      if (withVersion) {
        box.remove(key);
      }
    }
  }

  initSgbData() async {
    debugPrint('isUP ：$_isUpdate');
    _shijiTypeList.value = await api.getShijiType();
    var list = await api.getSgbList();
    _sgbDataList.value = list;
    debugPrint('list length:${list.length}');
  }

  refresh() async {
    await clearVisionStorage();
    await initSgbData();
  }

  /// 通过诗集类型获取数据和具体的诗集类型ID获取数据
  Future<List<SgbData>> getSgbDataListById(int id, ShijiTypeEnum type) async {
    await box.writeString(GetStorage.songListType, type.type);
    await box.writeInt(GetStorage.praiseListId, id);

    if (type == ShijiTypeEnum.shiji) {
      int index = shijiTypeList.indexWhere((element) => element.id == id);
      return getSgbDataListByShijiTypeIndex(index);
    }
    if (type == ShijiTypeEnum.gedan) {
      UserSong? song = await getSongListDetail('$id');
      List<UserSongDetail?> songDetailList = getUserSongDetailList(song?.list);
      return songDetailList
          .where((UserSongDetail? element) =>
              element != null && element.type == GeDanListType.geDan)
          .map(
              (sd) => sgbDataList.firstWhere((element) => element.id == sd!.id))
          .toList();
    }

    return [];
  }

  Future<UserSong?> getSongListDetail(String id) async {
    return await userApi.getSongListDetail(id);
  }

  void onSort() async {
    isDesc.value = !isDesc.value;
    try {
      await box.writeBool(GetStorage.sort, isDesc.value);
    } catch (e) {
      debugPrint('保存排序状态报错：${e.toString()} ${e.runtimeType}');
    }
  }

  /// 通过诗集类型索引获取数据
  List<SgbData> getSgbDataListByShijiTypeIndex(int index) {
    if (shijiTypeList.isEmpty) {
      return [];
    }
    int? shijiId = shijiTypeList[index].id;
    return getSgbDataListByShijiTypeById(shijiId);
  }

  // 通过诗集ID获取诗集类型
  List<SgbData> getSgbDataListByShijiTypeById(int shijiId) {
    return sgbDataList
        .where((element) => element.shijiIndex == shijiId)
        .toList()
      ..sort((a, b) => isDesc.value
          ? b.xuhao.compareTo(a.xuhao)
          : a.xuhao.compareTo(b.xuhao));
  }

  List<UserSongDetail?> getUserSongDetailList(String? ids) {
    if (ids == null || ids.isEmpty) {
      return [];
    }
    if (sgbDataList.isEmpty) {
      return getUserSongDetailList(ids);
    }

    return ids
        .split(',')
        .map((id) {
          if (id.isEmpty) {
            return null;
          }
          String cid = '';
          String? typeStr;
          try {
            [cid, typeStr] = id.split('|');
          } catch (e) {
            cid = id;
            typeStr = typeStr ?? '0';
          }
          if (cid.isEmpty) {
            return null;
          }

          int type = int.parse(typeStr);
          if (GeDanListType.values[type] == GeDanListType.geDan) {
            SgbData? sgbData =
                sgbDataList.firstWhereOrNull((element) => element.id == cid);

            if (sgbData == null) {
              return null;
            }

            ShijiType? shijiType = getShiJiTypeById(sgbData.shijiIndex);
            if (shijiType == null) {
              return null;
            }
            return UserSongDetail(
                id: cid,
                mulu: '${Utils.padZerow(sgbData.xuhao)}.${sgbData.title}',
                type: GeDanListType.geDan,
                shijiName: shijiType.name,
                ShijiTypeId: shijiType.id);
          }

          if (GeDanListType.values[type] == GeDanListType.jw) {
            return UserSongDetail(
                id: cid,
                mulu: cid,
                type: GeDanListType.jw,
                shijiName: '经文',
                ShijiTypeId: -1);
          }
        })
        .where((element) => element != null)
        .toList();
  }

  ShijiType? getShiJiTypeById(int shijiIndex) {
    ShijiType? shijiType =
        shijiTypeList.firstWhereOrNull((element) => element.id == shijiIndex);
    return shijiType;
  }

  /// 按标题搜索

  List<SgbData> searchTitle(String searchText) {
    if (sgbDataList.isEmpty) {
      return searchTitle(searchText);
    }
    return sgbDataList
        .where((element) =>
            ('${Utils.padZerow(element.xuhao)}.${element.title}')
                .contains(searchText))
        .toList();
  }
}
