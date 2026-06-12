import 'package:m/data/api/common.dart';
import 'package:m/data/module/active_member_params.dart';
import 'package:m/data/module/captcha_image.dart';
import 'package:m/data/module/login_params.dart';
import 'package:m/data/module/login_response.dart';
import 'package:m/data/module/register_params.dart';
import 'package:m/data/module/user.dart';
import 'package:m/data/module/user_song.dart';
class UserProvider extends CommonGetConnect{
  // /captchaImage
  Future<CaptchaImage?> captchaImage() async {
    dynamic result = await get('/captchaImage');
    if (result.body?['code'] == 200) {
      return CaptchaImage.fromJson(result.body);
    } else {
      return null;
    }
  }

  // /no-auth/h5/member/login
  Future<LoginResponse?> login(LoginParams request) async {
    dynamic result = await post('/no-auth/h5/member/login', request.toJson());
    return LoginResponse.fromJson(result.body);
  }

  // /no-auth/h5/member/register
  Future<LoginResponse> register(RegisterParams request) async {
    dynamic result =
        await post('/no-auth/h5/member/register', request.toJson());
    return LoginResponse.fromJson(result.body);
  }

  // /no-auth/h5/member/active_member
  Future<LoginResponse?> activeMember(ActiveMemberParams request) async {
    dynamic result =
        await post('/no-auth/h5/member/active_member', request.toJson());
    return LoginResponse.fromJson(result.body);
  }

  // /no-auth/h5/member/logout
  Future<LoginResponse?> logout() async {
    dynamic result = await post('/logout', '{}');
    return LoginResponse.fromJson(result.body);
  }

  // /getInfo
  Future<User?> getInfo() async {
    dynamic result = await get('/h5/member/getInfo');
    if (result.body?['code'] == 200) {
      return User.fromJson(result.body['user']);
    } else {
      return null;
    }
  }

  Future<List<UserSong>> getSongList() async {
    dynamic result = await get('/star/h5/song_list/list');
    if (result.body?['code'] == 200) {
      return (result.body['rows'] as List)
          .map((e) => UserSong.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  Future<UserSong?> getSongListDetail(String id) async {
    dynamic result = await get('/star/h5/song_list/$id');
    if (result.body?['code'] == 200) {
      return UserSong.fromJson(result.body['data']);
    } else {
      return null;
    }
  }

  // /star/h5/song_list/add
  Future<bool> addSongList(String name, [String? list]) async {
    dynamic result =
        await post('/star/h5/song_list', {'name': name, 'list': list ?? ''});
    if (result.body?['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> upSongList(
      {required String id, String? name, String? list}) async {
    dynamic result =
        await put('/star/h5/song_list', {'id': id, 'name': name, 'list': list});
    if (result.body?['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> delSongList(String id) async {
    dynamic result = await delete('/star/h5/song_list/$id');
    if (result.body?['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addSongListItem(String id, String songId) async {
    // star/h5/song_list/add_list
    dynamic result = await post(
        '/star/h5/song_list/add_list', {'id': id, 'list': songId},
        isLogin: true);
    if (result.body?['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> delSongListItem(String id, String songId) async {
    dynamic result = await request('/star/h5/song_list/del_list', 'delete',
        body: {'id': id, 'list': songId});
    if (result.body?['code'] == 200) {
      return true;
    } else {
      return false;
    }
  }

  // /star/h5/song_list/get_shou_cang
  Future<UserSong?> getShouCang() async {
    dynamic result = await get('/star/h5/song_list/get_shou_cang');
    if (result.body?['code'] == 200) {
      return UserSong.fromJson(result.body['data']);
    } else {
      return null;
    }
  }
}
