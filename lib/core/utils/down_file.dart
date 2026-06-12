import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:install_plugin/install_plugin.dart';
import 'package:m/core/constants/constants.dart';
import 'package:path/path.dart' as path;
import 'package:m/core/utils/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DownQueue {
  final String url;
  final Future<Response<dynamic>> Function() run;
  DownQueue(this.run, this.url);
}

class DownFile {
  static final Dio _dio = Dio();
  static final List<DownQueue> _downQueue = [];
  static bool _isDowning = false;

  /// 获取存储权限，仅Android需要
  Future<bool> permissionRequest() async {
    PermissionStatus manageExternalStorageStatus =
        await Permission.manageExternalStorage.request();
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted && manageExternalStorageStatus.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      Toast.showToast('未给到相关权限，请手动打开权限'.tr);
      openAppSettings();
      return false;
    }
    return false;
  }

  static Future<Response<dynamic>> _down(String url, String savePath,
          [void Function(int count, int total)? onReceiveProgress]) =>
      _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );

// 下载文件
  static Future<String> downloadFile(String url,
      {bool showLoading = true,
      String? fileName,
      // 开启子线程下载。
      bool background = true}) async {
    url = url.trimRight();
    if (!kIsWeb) {
      Directory? externalDir = await getDirectory();

      if (externalDir != null) {
        String extension = path.extension(url);
        fileName = fileName ?? path.basenameWithoutExtension(url);
        String savePath = '${externalDir.path}/$fileName$extension';

        // 检测文件是否存在
        if (await File(savePath).exists()) {
          debugPrint('文件已存在'.tr);
          return savePath;
        }
        ToastController? loading;
        if (showLoading) {
          loading = Toast.loading();
        }

        loading?.show();

        if (background && !showLoading) {
          // 开启子线程下载
          DownQueue? downQueue =
              _downQueue.firstWhereOrNull((element) => element.url == fileName);
          if (downQueue == null) {
            run() => _down(url, savePath, (count, total) {
                  // debugPrint("${(count / total * 100).round()}% $fileName");
                  loading?.progress = (count / total * 100).toInt();
                });
            _downQueue.add(DownQueue(run, fileName));
          }

          if (!_isDowning) {
            _processQueue();
          }
          return savePath;
        }

        try {
          await _dio.download(
            url,
            savePath,
            onReceiveProgress: (count, total) {
              // debugPrint("${count / total * 100}%-paath:$savePath");
              loading?.progress = (count / total * 100).toInt();
            },
          );
          return savePath;
        } on Exception catch (e) {
          debugPrint(e.toString());
          // Toast.showToast('下载失败:$e'.tr);
        } finally {
          loading?.close();
        }
      }
    }
    return url;
  }

  // 处理队列中的任务
  static Future<void> _processQueue() async {
    while (_downQueue.isNotEmpty) {
      var currentTask = _downQueue.first;
      _downQueue.removeAt(0); // 移除任务
      _isDowning = true;
      await currentTask.run(); // 执行任务
      await Future.delayed(const Duration(milliseconds: 100)); // 确保任务有足够的时间进行处理
      debugPrint('_processQueue 队列任务：${_downQueue.length}');
    }
    _isDowning = false;
  }

  /// 获取路径
  static Future<Directory?> getDirectory() async {
    Directory? externalDir;
    if (Platform.isAndroid) {
      externalDir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      externalDir = await getApplicationDocumentsDirectory();
    }
    Directory dir = Directory('${externalDir?.path}/download');
    if (!File(dir.path).existsSync()) {
      dir.createSync(recursive: true);
    }

    return dir;
  }

  /// 分享文件
  static Future<ShareResult> shareFile(String savePath,
      {String title = '分享文件'}) async {
    final params = ShareParams(files: [XFile(savePath)], title: title);
    final ShareResult result = await SharePlus.instance.share(params);
    if (result.status == ShareResultStatus.success) {
      // 分享成功
      Toast.showToast('分享成功'.tr);
    }

    return result;
  }

  /// 下载并分享文件
  static Future<void> shareDownFile(String url, String fileName) async {
    String? savePath = await DownFile.downloadFile(url, fileName: fileName);

    await DownFile.shareFile(savePath);
  }

  static Future<bool> isUrlFileExists({
    required String url,
  }) async {
    if (kIsWeb) {
      return false;
    }
    String savePath = await getUrlFIlePath(url: url);
    return await File(savePath).exists();
  }

  static Future<String> getUrlFIlePath({
    required String url,
  }) async {
    Directory? externalDir = await getDirectory();
    String username = path.basename(url);
    if (kDebugMode) {
      print('本地路径：${externalDir?.path}/$username');
    }
    return '${externalDir?.path}/$username';
  }

  /// 下载安装包，并安装
  static Future<void> downLoadApk({
    required String url,
  }) async {
    String savePath = await downloadFile(url);
    if (await isUrlFileExists(url: url)) {
      await installApk(savePath);
    }
  }

  static Future<void> installApk(String savePath) async {
    if (Platform.isAndroid) {
      final res = await InstallPlugin.install(savePath);
      bool isSuccess = res['isSuccess'];
      debugPrint("安装成功或着失败：res:${res['isSuccess']}");
      if (!isSuccess) {
        Toast.showToast('安装失败！请手动安装');

        ///安装失败，则打开默认浏览器
        await launchUrl(Uri.parse(appDownUrl));
      }
    }
  }
}
