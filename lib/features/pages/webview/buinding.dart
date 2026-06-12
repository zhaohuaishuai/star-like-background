import 'package:get/get.dart';
import 'package:m/features/pages/webview/controller.dart';

class WebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WebViewPageController());
  }
}
