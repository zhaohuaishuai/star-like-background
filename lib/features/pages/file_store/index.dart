import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/features/pages/file_store/controller.dart';

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
    // 如果获取失败，返回一个很早的时间
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  // 默认返回当前时间
  return DateTime.now();
}

/// 格式化日期时间
String _formatDateTime(DateTime dateTime) {
  // 显示完整的日期和时间格式：YYYY-MM-DD HH:mm:ss
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
}

/// 获取文件扩展名
String _getFileExtension(String filePath) {
  try {
    int lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < filePath.length - 1) {
      String extension = filePath.substring(lastDotIndex + 1).toLowerCase();
      return '.$extension';
    }
  } catch (e) {
    debugPrint('获取文件扩展名失败: $e');
  }
  return '.unknown'; // 如果无法获取扩展名，返回.unknown
}

class FileStorePage extends GetView<FileStoreController> {
  const FileStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppBar(
              title: controller.isInSelectionMode.value
                  ? Text('${controller.selectedFiles.length} 个项目已选中')
                  : Text('文件缓存 (${controller.getTotalFileSize()})'),
              backgroundColor: null,
              actions: [
                if (controller.isInSelectionMode.value)
                  IconButton(
                    icon: Icon(
                      controller.selectedFiles.length ==
                              controller.fileList.length
                          ? Icons.deselect
                          : Icons.select_all,
                    ),
                    onPressed: () {
                      controller.toggleSelectAll();
                    },
                    tooltip: controller.selectedFiles.length ==
                            controller.fileList.length
                        ? '取消全选'
                        : '全选',
                  ),
                if (controller.isInSelectionMode.value)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      bool success = await controller.deleteSelectedFiles();
                      if (success) {
                        controller.refreshFileList();
                      }
                    },
                    tooltip: '删除选中文件',
                  ),
                if (controller.isInSelectionMode.value)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clearSelection();
                    },
                    tooltip: '取消选择',
                  ),
              ],
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.fileList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无文件',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        var list = ListView.builder(
          itemCount: controller.fileList.length,
          itemBuilder: (context, index) {
            FileSystemEntity file = controller.fileList[index];
            // 检查当前文件是否被选中
            bool isSelected = controller.selectedFiles.contains(file);

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: StarThemeData.spacing,
                vertical: 4,
              ),
              child: Material(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                elevation: isSelected ? 2 : 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    if (controller.isInSelectionMode.value) {
                      controller.toggleSelection(file);
                    }
                  },
                  onLongPress: () {
                    controller.toggleSelection(file);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Obx(() {
                          bool isSelected =
                              controller.selectedFiles.contains(file);
                          return Checkbox(
                            value: isSelected,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                            ),
                            onChanged: (bool? value) {
                              controller.toggleSelection(file);
                            },
                          );
                        }),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      file.path.split('/').last, // 只显示文件名
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // 显示文件扩展名
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getFileExtension(file.path),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file.path, // 显示完整路径
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(
                                    _getFileModifiedTime(file)), // 显示修改时间
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.formatFileSize(
                                    controller.getFileSize(file)), // 显示文件大小
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
        return list;
      }),
    );
  }
}
