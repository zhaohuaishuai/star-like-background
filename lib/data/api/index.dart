import 'package:get/get.dart';
import 'package:m/data/api/common.dart';
import 'package:m/data/module/app_version.dart';
import 'package:m/data/module/notice.dart';
import 'package:m/data/module/recommend.dart';
import 'package:m/data/module/user_song.dart';

class IndexProvider extends CommonGetConnect {
  Future<List<Notice>> getNoticeList() async { 
    Response<dynamic> res = await request('/system/notice/list','get',query: {'status':'0'});
    if (res.body?['code'] == 200) {
      final List<dynamic> rows = res.body['rows'];
      return rows.map((json) => Notice.fromJson(json)).toList();
    }
    return [];
  }

  // /system/notice/3
  Future<Notice?> getNoticeDetail(int id) async {
    Response<dynamic> res = await get('/system/notice/$id');
    if (res.body?['code'] == 200) {
      return Notice.fromJson(res.body['data']);
    }
    return null;
  }

  Future<List<Recommend>> recommend() async {
    Response<dynamic> res = await get('/star/recommend');
    final List<dynamic> rows = res.body['data'];
    return rows.map((json) => Recommend.fromJson(json)).toList();
  }

  /// 客户端首页推荐歌单列表（按推荐时间倒序）
  Future<List<UserSong>> recommendSongList() async {
    Response<dynamic> res = await get('/star/h5/song_list/recommend');
    if (res.body?['code'] == 200) {
      final List<dynamic> rows = res.body['data'] as List<dynamic>;
      return rows
          .map((json) => UserSong.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }


  Future<AppVersion?> getAppVersion() async {
    Response<dynamic> res = await get('/start/appversion/new');
    if (res.body?['code'] == 200) {
      return AppVersion.fromJson(res.body['data']);
    } 
    return null; 
  }

}
