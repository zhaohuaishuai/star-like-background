import 'package:get/get.dart';
import 'package:m/features/pages/my/controller.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyController());
  }
}
