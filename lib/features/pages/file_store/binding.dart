import 'package:get/get.dart';
import 'package:m/features/pages/file_store/controller.dart';

class FileStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileStoreController>(() => FileStoreController());
  }
}
