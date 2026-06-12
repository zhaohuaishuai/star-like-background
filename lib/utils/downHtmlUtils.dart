import 'dart:html' as html;

class downFile {
  static Future down(String fileName, String url, [progressCallback]) async {
    // SnackbarController snackbarController = Get.snackbar(
    //   "提示",
    //   "正在下载",
    //   colorText: Colors.white,
    //   showProgressIndicator:true,
    //   backgroundGradient: AppColor.appPlayerBackgroundGradient,
    //   backgroundColor: Colors.white,
    //   icon:Icon(Icons.bubble_chart_outlined,color:Colors.yellowAccent),
    //   duration: Duration(hours: 1),
    //
    // );
    print("这是web-->${url}?down=1");
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = '${url}?down=1'
      ..style.display = 'none'
      ..download = fileName;
    html.document.body!.children.add(anchor);
    // download
    anchor.click();
    // cleanup
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    // snackbarController.close();
  }

  // 假的方法
  static savePhont(String fileName, String url) {}
}
