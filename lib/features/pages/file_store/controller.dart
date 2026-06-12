import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/utils/down_file.dart';
import 'package:m/core/utils/toast.dart';

class FileStoreController extends GetxController {
  FileStoreController();

  // 用于跟踪选中的文件
  RxList<FileSystemEntity> selectedFiles = <FileSystemEntity>[].obs;

  // 是否处于选择模式
  RxBool isInSelectionMode = false.obs;

  RxList<FileSystemEntity> fileList = <FileSystemEntity>[].obs;

  // 加载状态
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载文件列表
    getFileList();
  }

  Future<List<FileSystemEntity>> getFileList() async {
    isLoading.value = true; // 开始加载

    Directory? externalDir = await DownFile.getDirectory();
    if (externalDir != null) {
      List<FileSystemEntity> files = await externalDir.list().toList();

      // 按修改时间倒序排序（最新的在最前面）
      files.sort((a, b) {
        DateTime modifiedA = _getFileModifiedTime(a);
        DateTime modifiedB = _getFileModifiedTime(b);
        return modifiedB.compareTo(modifiedA); // 倒序排列
      });

      debugPrint(files.toString());
      fileList.value = files;
      isLoading.value = false; // 加载完成
      return files;
    }
    fileList.value = [];
    isLoading.value = false; // 加载完成
    return [];
  }

  /// 获取文件的修改时间
  DateTime _getFileModifiedTime(FileSystemEntity file) {
    try {
      if (file is File) {
        return file.lastModifiedSync();
      } else if (file is Directory) {
        return file.statSync().modified;
      }
    } catch (e) {
      debugPrint('获取文件修改时间失败: $e');
      // 如果获取失败，返回一个很早的时间，这样它会被排到最后
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    // 默认返回当前时间
    return DateTime.now();
  }

  /// 获取文件大小（字节）
  int getFileSize(FileSystemEntity file) {
    try {
      if (file is File) {
        return file.lengthSync();
      } else if (file is Directory) {
        // 计算目录总大小
        int totalSize = 0;
        try {
          List<FileSystemEntity> entities = file.listSync(recursive: true);
          for (FileSystemEntity entity in entities) {
            if (entity is File) {
              try {
                totalSize += entity.lengthSync();
              } catch (e) {
                debugPrint('获取文件大小失败: $entity.path, 错误: $e');
              }
            }
          }
        } catch (e) {
          debugPrint('遍历目录失败: $file.path, 错误: $e');
        }
        return totalSize;
      }
    } catch (e) {
      debugPrint('获取文件大小失败: $e');
    }
    return 0; // 如果获取失败，返回0
  }

  /// 格式化文件大小显示
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } else {
      double mb = bytes / (1024 * 1024);
      if (bytes >= 1024 * 1024 * 1024) {
        // 大于等于1GB，按GB显示
        double gb = bytes / (1024 * 1024 * 1024);
        return '${gb.toStringAsFixed(2)} GB';
      } else {
        // 小于1GB，按MB显示
        return '${mb.toStringAsFixed(2)} MB';
      }
    }
  }

  /// 计算总文件大小
  String getTotalFileSize() {
    int totalBytes = 0;
    for (FileSystemEntity file in fileList) {
      totalBytes += getFileSize(file);
    }
    return formatFileSize(totalBytes);
  }

  /// 切换文件选择状态
  void toggleSelection(FileSystemEntity file) {
    if (selectedFiles.contains(file)) {
      selectedFiles.remove(file);
    } else {
      selectedFiles.add(file);
    }

    // 如果没有选中任何文件，则退出选择模式
    if (selectedFiles.isEmpty) {
      isInSelectionMode.value = false;
    } else {
      isInSelectionMode.value = true;
    }
  }

  /// 清除所有选择
  void clearSelection() {
    selectedFiles.clear();
    isInSelectionMode.value = false;
  }

  /// 删除选中的文件
  Future<bool> deleteSelectedFiles() async {
    if (selectedFiles.isEmpty) {
      Toast.showToast('请选择要删除的文件');
      return false;
    }

    setLoading(true); // 开始删除时设置为加载状态
    try {
      for (FileSystemEntity file in selectedFiles) {
        await file.delete(recursive: true); // 使用recursive: true来确保目录也能被删除
      }
      Toast.showToast('${selectedFiles.length}个文件已成功删除');
      selectedFiles.clear();
      isInSelectionMode.value = false;
      await refreshFileList(); // 刷新文件列表
      return true;
    } catch (e) {
      debugPrint('删除文件失败: $e');
      Toast.showToast('部分文件删除失败: $e');
      return false;
    } finally {
      setLoading(false); // 确保无论成功或失败都结束加载状态
    }
  }

  /// 全选或取消全选
  void toggleSelectAll() {
    if (selectedFiles.length == fileList.length) {
      // 如果已经全选，则取消全选
      clearSelection();
    } else {
      // 否则全选
      selectedFiles.assignAll(fileList);
      isInSelectionMode.value = true;
    }
  }

  /// 刷新文件列表
  Future<void> refreshFileList() async {
    // 重新获取文件列表
    await getFileList();
  }

  /// 设置加载状态
  void setLoading(bool status) {
    isLoading.value = status;
  }
}
