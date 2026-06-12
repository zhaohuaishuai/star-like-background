import 'package:get/get.dart';
import 'package:m/data/api/common.dart';
import 'package:m/data/module/sgb_data.dart';
import 'package:m/data/module/shiji_type.dart';
import 'package:m/data/module/song.dart';

class SgbProvider extends CommonGetConnect {
  Future<String> getVersion() async {
    Response<dynamic> res = await get('/start/zanmei/version');
    return res.body['msg'];
  }

  Future<List<SgbData>> getSgbList() async {
    Response<dynamic> res = await get('/start/zanmei/sgbList',isCache: true);
    final List<dynamic> rows = res.body['rows'];
    return rows.map((json) => SgbData.fromJson(json)).toList();
  }

  Future<List<ShijiType>> getShijiType() async {
    Response<dynamic> res =
        await get('/start/shijidb/list?pageNum=1&pageSize=100&isUpper=1',isCache: true);
    final List<dynamic> rows = res.body['rows'];
    return rows.map((json) => ShijiType.fromJson(json)).toList();
  }

  Future<Song> getSgbDetail(String id) async {
    Response<dynamic> res = await get('/start/zanmei/sgb/$id',isCache: true);
    final data = res.body['data'];
    return Song.fromJson(data);
  }

  Future<List<Song>> searchByLryic(String keyword) async {
    Response<dynamic> res =
        await get('/start/zanmei/searchByLryic', query: {'keyword': keyword});
    final List<dynamic> rows = res.body['data'];
    return rows.map((json) => Song.fromJson(json)).toList();
  }
}
