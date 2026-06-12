 
import 'package:m/data/module/user_song.dart';

import 'package:m/data/services/user.dart';
import 'package:m/features/pages/gedanlist/controller.dart';

class MyController extends GeDanListControllerAbs {
  @override
  Future<void> init() async {
    super.init();
    // 监听收藏数据变化（登录/匿名均支持）
    UserService.to.shouCangListen((newValue) {
      song.value = newValue;
    });
  }

  @override
  Future<UserSong?> getDataSource() async {
    return await UserService.to.getShouCang();
  }
}
