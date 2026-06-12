import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// 电池优化处理工具类
class BatteryOptimizationUtils {
  /// 请求忽略电池优化
  /// 注意：这只在Android设备上有效
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      try {
        bool isIgnoringBatteryOptimizations =
            await Permission.ignoreBatteryOptimizations.isGranted;
        if (kDebugMode) {
          print('电池优化状态检查: $isIgnoringBatteryOptimizations');
        }
        if (!isIgnoringBatteryOptimizations) {
          // 请求忽略电池优化
          if (kDebugMode) {
            print('请求忽略电池优化');
          }
          PermissionStatus status =
              await Permission.ignoreBatteryOptimizations.request();
          if (kDebugMode) {
            print('电池优化状态请求: $status');
          }

          // 如果权限被拒绝或永久拒绝，引导用户到设置页面
          if (status.isDenied || status.isPermanentlyDenied) {
            if (kDebugMode) {
              print('电池优化权限被拒绝，引导用户到设置页面');
            }
            // 延迟一点时间再打开设置页面，避免冲突
            await Future.delayed(const Duration(milliseconds: 500));
            await openBatterySettings();
          } else if (status.isGranted) {
            // 请求成功，更新状态
            if (kDebugMode) {
              print('电池优化权限已授予');
            }
          }
        } else {
          if (kDebugMode) {
            print('电池优化权限已被授予');
          }
        }
      } catch (e) {
        // 处理异常情况
        if (kDebugMode) {
          print('请求忽略电池优化时出错: $e');
        }
      }
    }
  }

  /// 检查是否已忽略电池优化
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (Platform.isAndroid) {
      try {
        return await Permission.ignoreBatteryOptimizations.isGranted;
      } catch (e) {
        print('检查电池优化状态时出错: $e');
        return false;
      }
    }
    return true; // iOS和其他平台默认返回true
  }

  /// 打开应用设置页面
  static Future<void> openBatterySettings() async {
    if (Platform.isAndroid) {
      try {
        await openAppSettings();
      } catch (e) {
        print('打开应用设置时出错: $e');
      }
    }
  }
}
