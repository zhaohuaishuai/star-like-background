import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/index.dart';
import 'package:m/data/module/notice.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPageController extends GetxController {
  IndexProvider api = Get.put<IndexProvider>(IndexProvider());
  late final WebViewController _controller = WebViewController();
  WebViewController get webViewController => _controller;
  Notice? notice;
  RxString title = ''.obs;

  Future<void> _loadHtmlFromAssets() async {
    if (notice?.noticeType == (NoticeTypeEnum.notice) ||
        notice?.noticeType == (NoticeTypeEnum.noticeBoard)) {
      loadHtmlStr();
      return;
    }
    loadWebView();
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('WebViewController init');
    var id = Get.parameters['id'];
    var url = Get.parameters['url'];
    debugPrint('WebViewController id: $id, url: $url');
    title.value = Get.parameters['title'] ?? '通知详情'.tr;
    if (url != null) {
      // 对 URL 进行解码，以还原 # 后面的路径
      var decodedUrl = Uri.decodeComponent(url);
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              return handleNavigationRequest(request);
            },
          ),
        )
        ..addJavaScriptChannel(webViewJsLet,
            onMessageReceived: (JavaScriptMessage message) {
          debugPrint('message:${message.message}');
          if (message.message == WebViewMethodEnum.back.toString()) {
            WebViewMethodEnum.back.call();
          }
        })
        ..loadRequest(Uri.parse(decodedUrl));
      return;
    }
    if (id != null) {
      // 检查 id 是否是链接（以 http 开头）
      if (id.startsWith('http://') || id.startsWith('https://')) {
        // 直接加载链接
        _controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                return handleNavigationRequest(request);
              },
            ),
          )
          ..loadRequest(Uri.parse(id));
      } else {
        // 否则按原逻辑获取通知详情
        api.getNoticeDetail(int.parse(id)).then((value) {
          if (value != null) {
            notice = value;
            _loadHtmlFromAssets();
            // debugPrint(
            //     "WebViewController title: ${value.title}\n ${value.content}");
          }
        });
      }
    }
  }

  void loadHtmlStr() async {
    String css = await rootBundle.loadString('assets/www/styles/style.css');
    String html = ''' <!DOCTYPE html>  <html lang="en"> <head>  <style>  $css 
            .ql-video { width: 100%; height: 1000px; } </style>  </head> <body class="ql-container ql-snow ql-editor"> 
            <h1 style="text-align:center;">${notice?.title}</h1>   ${notice?.content}   </body> </html> ''';
    _controller.loadHtmlString(html);
  }

  loadWebView() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return handleNavigationRequest(request);
          },
        ),
      )
      ..loadRequest(Uri.parse(notice!.content));
  }

  /// 处理播放页跳转链接
  /// 检查是否是特定格式的链接，如果是则使用内部路由跳转
  /// 返回 NavigationDecision.prevent 表示已处理并阻止跳转，返回 null 表示未匹配该规则
  NavigationDecision? _handlePlayNewLink(NavigationRequest request) {
    if (request.url.startsWith('https://star.top237.top/#/playnew/')) {
      debugPrint('Detected playnew link: ${request.url}');

      // 从URL中提取ID和shijiIndex
      // URL格式: https://star.top237.top/#/playnew/c641c92ca652a253095ec76538ef67bc/8/shiji?from=/sgb
      try {
        // 移除基础URL部分
        String path = request.url.replaceFirst('https://star.top237.top/#', '');

        // 解析路径
        List<String> segments = path.split('/');

        // 查找playnew的位置
        int playnewIndex = segments.indexOf('playnew');
        if (playnewIndex != -1 && segments.length > playnewIndex + 2) {
          String id = segments[playnewIndex + 1]; // ID是playnew后的第一个参数
          String shijiIndexStr =
              segments[playnewIndex + 2]; // shijiIndex是playnew后的第二个参数

          // 尝试解析shijiIndex为整数
          int? shijiIndex = int.tryParse(shijiIndexStr);

          if (id.isNotEmpty && shijiIndex != null) {
            debugPrint('Extracted id: $id, shijiIndex: $shijiIndex');

            // 调用内部路由方法
            RouterUtils.toPlayer(id, shijiIndex);

            // 阻止WebView中的跳转，因为我们要在应用内部处理
            return NavigationDecision.prevent;
          } else {
            debugPrint('Failed to extract parameters from URL: ${request.url}');
          }
        }
      } catch (e) {
        debugPrint('Error parsing URL: $e');
      }
    }

    return null; // 未匹配到该规则
  }

  /// 处理导航请求，拦截a标签跳转
  /// 返回 NavigationDecision.prevent 表示阻止跳转
  /// 返回 NavigationDecision.navigate 表示允许跳转
  NavigationDecision handleNavigationRequest(NavigationRequest request) {
    debugPrint('WebView navigation request: ${request.url}');

    // 检查是否是播放页跳转链接
    NavigationDecision? playNewResult = _handlePlayNewLink(request);
    if (playNewResult != null) {
      return playNewResult;
    }

    // 示例：阻止特定域名的跳转
    // if (!request.url.contains('allowed-domain.com')) {
    //   debugPrint('Navigation to ${request.url} blocked');
    //   return NavigationDecision.prevent;
    // }

    // 示例：对于外部链接，在外部浏览器打开而不是在WebView中打开
    // if (!request.url.contains('yourdomain.com')) {
    //   launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
    //   return NavigationDecision.prevent; // 阻止在WebView中打开
    // }

    // 示例：只允许主框架导航，阻止iframe等其他框架的导航
    // 注意：不同版本的webview_flutter可能有不同的API
    // if (request.isMainFrame != null && !request.isMainFrame!) {
    //   debugPrint('Navigation in sub-frame prevented: ${request.url}');
    //   return NavigationDecision.prevent;
    // }

    // 允许同域跳转，阻止外域跳转
    // String currentDomain = Uri.parse(_controller.currentUrl()).host;
    // String targetDomain = Uri.parse(request.url).host;
    // if (currentDomain != targetDomain) {
    //   debugPrint('Cross-domain navigation blocked: ${request.url}');
    //   return NavigationDecision.prevent;
    // }

    // 默认允许跳转
    return NavigationDecision.navigate;
  }
}
