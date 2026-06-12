// import 'package:flowder/flowder.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:convert';
import 'dart:developer';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:md5_file_checksum/md5_file_checksum.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../config/color.dart';
import 'dart:io';
import 'package:get/get.dart';
import "package:dio/dio.dart";
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:android_path_provider/android_path_provider.dart';

import 'package:convert/convert.dart';

class downPer {
  /**
   *  获取外部文件权限
   */
  static Future<bool> isGranted() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      PermissionStatus permissionStatus = await Permission.storage.request();
      if (permissionStatus.isDenied || permissionStatus.isLimited) {
        return false;
      }
    }
    return true;
  }

/**
 * 打开文件权限
 */
  static Future<bool> isOpenFile() async {
    // 打开文件权限
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      PermissionStatus permissionStatus =
          await Permission.manageExternalStorage.request();
      if (permissionStatus.isDenied || permissionStatus.isLimited) {
        return false;
      }
    }
    return true;
  }

  /**
   * 安装应用权限
   */
  static Future<bool> ensureInstallPackagesPermission() async {
    var status = await Permission.requestInstallPackages.status;

    if (status.isDenied || status.isRestricted) {
      PermissionStatus permissionResult =
          await Permission.requestInstallPackages.request();

      if (permissionResult.isDenied || permissionResult.isLimited) {
        return false;
      }
    }
    return true;
  }

/**
 * 检查文件是否存在
 */
  static Future<bool> testFile(String fileName) async {
    // 生成文件路径
    print('filePath:$fileName');
    // 初始化文件
    File file = File(fileName);
    // 检查文件是否存在
    bool fileExists = await file.exists();
    return fileExists;
  }

  /**
   * 获取下载目录
   */
  static get downloadsPath async {
    // return Future(() => "/download");
    return await AndroidPathProvider.downloadsPath;

  }

  static Future<String> getSavePath(String url, String fileName) async {
    bool isGranted = await downPer.isGranted();
    String dirPath = await downPer.downloadsPath;
    RegExp regExp = RegExp(r"(?<=\.)\w+$");
    String? ext = regExp.firstMatch(url)?.group(0);
    var savePath = '$dirPath/$fileName.$ext';
    return savePath;
  }

  /**
   * 遍历获取目录下的文件路径
   */
  static Future<List<String>> getDirFilesPath(String dirPath) async {
    List<FileSystemEntity> files = [];
    bool isExists = await Directory(dirPath).exists();
    if (isExists) {
      files = Directory(dirPath).listSync();
      return files.map((file) => file.path).toList();
    } else {
      return [];
    }
  }
}

class downFile {
  static Future<String> setPath() async {
    Directory _path = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid == TargetPlatform.android) {
      _path = await getExternalStorageDirectory() as Directory;
    }
    String _localPath = _path.path + Platform.pathSeparator + 'StarDownload';
    print('localPath-->${_localPath}');
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create(recursive: true);
    }
    return _localPath;
    // return '';
  }

  static Future down(String fileName, String url, [progressCallback]) async {
    print('下载链接-->$url');
    String dirPath = await downPer.downloadsPath;
    var savePath = '$dirPath/star_down/${fileName}';
    // print('保存路径-->$savePath');
    await downPer.isGranted();
    bool fileIsExit = await downPer.testFile(savePath);
    print('文件是否存在：$fileIsExit');
    if (fileIsExit) {
      String md5 = await filemd5(savePath);
      print("md5较验-->" + md5);
      Get.snackbar(
        '提示',
        "文件已经存在！",
        backgroundColor: Colors.white,
        duration: Duration(milliseconds: 1000),
        icon: Icon(
          Icons.close_outlined,
          color: Colors.redAccent,
        ),
      );
      return;
    }
    SnackbarController snackbarController = Get.snackbar(
      "提示",
      "正在下载",
      colorText: Colors.white,
      showProgressIndicator: true,
      backgroundGradient: AppColor.appPlayerBackgroundGradient,
      backgroundColor: Colors.white,
      icon: Icon(Icons.bubble_chart_outlined, color: Colors.yellowAccent),
      duration: Duration(hours: 1),
    );

    Dio dio = Dio();
    try {
      await dio.download(url, savePath,
          onReceiveProgress: (received, total) async {
        final progress = (received / total) * 100;
        // print ((progress).toStringAsFixed(0) + "%");
        if (progressCallback != null) {
          progressCallback(progress);
        }
        if (progress >= 100) {
          snackbarController.close();
          // 打开文件权限
          bool hasOpenFile = await downPer.isOpenFile();
          // 安装应用权限
          bool hasPerInst = await downPer.ensureInstallPackagesPermission();
          if (!hasPerInst || !hasOpenFile) {
            Get.snackbar("提示", "请授予安装应用的权限");
            return;
          }
          final openResult = await OpenFile.open(savePath);
          var message = openResult.message;
          print('打开结果-->$message');
        }
      });
    } catch (err) {
      print('err-->$err');
      snackbarController.close();
      Get.snackbar(
        '提示',
        "下载失败，请尝试重新点击下载",
        backgroundColor: Colors.white,
        duration: Duration(milliseconds: 1000),
        icon: Icon(
          Icons.close_outlined,
          color: Colors.redAccent,
        ),
      );
    }
  }

  static Future savePhont(String fileName, String url) async {
    SnackbarController snackbarController = Get.snackbar(
      "提示",
      "正在下载",
      colorText: Colors.white,
      showProgressIndicator: true,
      backgroundGradient: AppColor.appPlayerBackgroundGradient,
      backgroundColor: Colors.white,
      icon: Icon(Icons.bubble_chart_outlined, color: Colors.yellowAccent),
      duration: Duration(hours: 1),
    );
    var response;
    try {
      response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
    } catch (err) {
      Get.snackbar(
        "提示",
        "下载图片失败",
        colorText: Colors.white,
        backgroundGradient: AppColor.appPlayerBackgroundGradient,
        backgroundColor: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.red),
        duration: Duration(seconds: 1),
      );
      snackbarController.close();
    }
    if (response == null) return;
    try {
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          name: fileName);
      Get.snackbar(
        "提示",
        "图片保存到相册成功",
        colorText: Colors.white,
        backgroundGradient: AppColor.appPlayerBackgroundGradient,
        backgroundColor: Colors.white,
        icon: Icon(Icons.check_box, color: Colors.green),
        duration: Duration(seconds: 1),
      );
    } catch (err) {
      print(err);
      Get.snackbar(
        "提示",
        "下载图片失败",
        colorText: Colors.white,
        backgroundGradient: AppColor.appPlayerBackgroundGradient,
        backgroundColor: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.red),
        duration: Duration(seconds: 1),
      );
    } finally {
      snackbarController.close();
    }
  }
  // 获取文件的md5
  static Future<String> filemd5(String filePath) async {
    await downPer.isOpenFile();
    var res = await Md5FileChecksum.getFileChecksum(filePath: filePath);
    return hex.encode(base64Decode(res)); // 283M文件用时1825毫秒
  }
}
