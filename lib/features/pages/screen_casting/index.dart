import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/constants/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ScreenCatingPage extends StatefulWidget {
  const ScreenCatingPage({super.key});
  @override
  State<ScreenCatingPage> createState() => _ScreenCatingPageState();
}

class _ScreenCatingPageState extends State<ScreenCatingPage> {
  late WebViewController _webViewController;
  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
    _webViewController
      ..loadRequest(Uri.parse('https://star.top237.top/#/t'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(webViewJsLet,
          onMessageReceived: (JavaScriptMessage message) {
        debugPrint('message:${message.message}');
        if (message.message == WebViewMethodEnum.back.toString()) {
          WebViewMethodEnum.back.call();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        debugPrint('onPopInvoked:$didPop');
        String? currentUrl = await _webViewController.currentUrl();
        debugPrint('currentUrl:$currentUrl');
        // 不是加载的一级页面，则执行js代码的回退
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return;
        }
        Get.back();
      },
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                _webViewController.clearCache();
                _webViewController.reload();
              },
            ),
          ),
        ],
      ),
    );
  }
}
