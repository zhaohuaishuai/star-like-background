import 'package:get/get.dart';
import 'package:m/features/pages/search/controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchPageController());
  }
}
