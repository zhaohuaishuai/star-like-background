 
import 'package:m/data/module/user_song.dart';

import 'package:m/data/services/user.dart';
import 'package:m/features/pages/gedanlist/controller.dart';

class MyController extends GeDanListControllerAbs {
  @override
  Future<void> init() async {
    super.init();
    if (UserService.to.isLogin) {
      UserService.to.shouCangListen((newValue) {
        song.value = newValue;
      });
    }

    UserService.to.shouCangListen((newValue) { 
       song.value = newValue;
    });
  }

  @override
  Future<UserSong?> getDataSource() async {
    return await UserService.to.getShouCang();
  }
}
