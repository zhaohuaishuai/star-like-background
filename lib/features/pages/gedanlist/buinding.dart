import 'package:get/get.dart';
import 'package:m/features/pages/gedanlist/controller.dart';

class GeDanListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GeDanListController());
  }
}
