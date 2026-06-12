import 'package:get/get.dart';

import 'controller.dart';

class SgbBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SgbController());
  }
}
