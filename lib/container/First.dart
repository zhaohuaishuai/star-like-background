import 'package:get/get.dart';
import '../api/api.dart';
import '../type/sgbType.dart';

class First extends GetxController {
  final SgbProvider api = SgbProvider();
  final informList = ['关注微信公众号：[发光如星top237]， 不迷路', '祷游237 新加坡'].obs;
  final notices = List<Notice>.empty(growable: true).obs;
  @override
  void onInit() async {
    print("first init");
    super.onInit();
    try{
      dynamic res = await api.getNoticeList();
      List<dynamic> rows = res.body['rows'];
      List<Notice> list = rows.map((item){
        return Notice.fromJson(item);
      }).toList();
      print("notices:${list}");
      this.notices.value = list;
    }catch(err){
      print(err);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class FirstBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<First>(First());
  }
}
