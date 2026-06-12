import 'package:dio/dio.dart';
import 'package:m/data/api/dio_common.dart';
import 'package:m/features/pages/bible/module/bible_dict.dart';

class BibleProvider {
  Future<List<BibleDict>> getBibleDictList() async {
    Response<dynamic> res =
        await dioCommon.get('/no-auth/bible/bible_dict', isCache: true);
    if (res.body?['code'] == 200) {
      final List<dynamic> rows = res.body['data'];
      return rows.map((json) => BibleDict.fromJson(json)).toList();
    }
    return [];
  }

  /// 获取圣经数据库版本号
  Future<String?> getBibleVersion() async {
    try {
      Response<dynamic> res =
          await dioCommon.get('/no-auth/bible/version', isCache: false);

      print('获取圣经版本成功: ${res.body}');
      if (res.body?['code'] == 200) {
        final data = res.body['msg'];
        if (data != null) {
          return data;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('获取圣经版本失败: $e');
      return null;
    }
  }
}
