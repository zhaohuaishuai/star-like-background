import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/features/pages/webview/controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends GetWidget<WebViewPageController> {
  const WebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value)),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(
            controller: controller.webViewController,
          ),
        ),
      ),
    );
  }
}
