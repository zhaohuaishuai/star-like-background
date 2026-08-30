import 'package:get/get.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/features/pages/playnew/controller.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/lyric_ui.dart';

/// 设置页控制器，管理设置项状态并持久化到本地存储
class SettingsController extends GetxController {
  SettingsController();

  final GetStorage box = GetStorage();

  /// 歌词字体大小（普通行字号）
  final RxDouble lyricFontSize = RxDouble(LyricUI.cDefaultSize);

  @override
  void onInit() {
    super.onInit();
    _loadLyricFontSize();
  }

  /// 从本地存储读取歌词字号
  Future<void> _loadLyricFontSize() async {
    final double? saved = await box.readDouble(LyricUI.lyricFontSizeKey);
    if (saved != null) {
      lyricFontSize.value = saved;
    }
  }

  /// 更新歌词字号并持久化，同时同步到播放页（若存在）
  Future<void> setLyricFontSize(double value) async {
    lyricFontSize.value = value;
    await box.writeDouble(LyricUI.lyricFontSizeKey, value);
    if (Get.isRegistered<PlayNewController>()) {
      Get.find<PlayNewController>().lyricFontSize.value = value;
    }
  }
}
