import 'package:Shine_like_a_star/type/sgbType.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../container/First.dart';
import '../config/color.dart';
class TichTextPage extends GetView<First> {
  TichTextPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var id = Get.parameters['id'];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.xuhaoFontColor,
        ),
        body: Container(
          child: WebView(
            initialUrl: "https://star.top237.top/#/tichTextPage/" + id.toString(),
            javascriptMode: JavascriptMode.unrestricted,
          ),
        )
    );
  }
}
