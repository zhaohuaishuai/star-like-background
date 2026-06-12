import 'package:get/get.dart';
import 'package:m/features/pages/playnew/controller.dart';

class PlayNewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlayNewController());
  }
}
