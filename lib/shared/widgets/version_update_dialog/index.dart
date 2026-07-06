import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/utils/down_file.dart';
import 'package:m/data/module/app_version.dart';

/// 版本更新弹窗组件
///
/// 设计理念：「天光」
/// 以教堂彩绘玻璃透入的天光为灵感，结合温暖庄重的视觉语言，
/// 营造兼具神圣感与现代感的版本更新提示体验。
///
/// 色彩基调：深赭石底 × 金红渐变 × 暖白文字
/// 质感表现：轻微玻璃拟态 + 渐变光晕 + 精致描边
class VersionUpdateDialog extends StatelessWidget {
  final AppVersion appVersion;

  const VersionUpdateDialog({
    Key? key,
    required this.appVersion,
  }) : super(key: key);

  /// 以动画方式弹出更新对话框
  static void show(AppVersion appVersion) {
    Get.dialog(
      VersionUpdateDialog(appVersion: appVersion),
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final theme = Get.theme;

    return PopScope(
      canPop: false,
      child: Center(
        child: SingleChildScrollView(
          child: _AnimatedEntry(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── 顶部装饰区域 (天光意象) ──
                    _buildHeader(isDark, theme),

                    // ── 内容区域 ──
                    _buildContent(context, isDark, theme),

                    // ── 底部按钮 ──
                    _buildActions(isDark, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部装饰区域：渐变色天穹 + 十字星芒光晕
  Widget _buildHeader(bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2D0A0A),
                  const Color(0xFF4A0E0E),
                  const Color(0xFF6B1A1A),
                ]
              : [
                  const Color(0xFF8B1A1A),
                  const Color(0xFFB22222),
                  const Color(0xFFDC3545),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B0000).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 十字星芒光晕装饰
          _buildGlowIcon(isDark),
          const SizedBox(height: 16),

          // 主标题
          Text(
            '版本更新'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 4,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // 版本号徽章
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.new_releases_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'v ${appVersion.version}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 十字星芒光晕图标
  Widget _buildGlowIcon(bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.star_rounded,
        size: 28,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  /// 中间内容区域：更新说明
  Widget _buildContent(BuildContext context, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 小标题
          Text(
            '更新内容'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF6B7280),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),

          // 装饰分割线
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDC3545).withOpacity(0.6),
                  const Color(0xFFDC3545).withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 更新内容文本
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
              ),
            ),
            child: Text(
              appVersion.context,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: isDark
                    ? Colors.white.withOpacity(0.85)
                    : const Color(0xFF374151),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部按钮区域
  Widget _buildActions(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        children: [
          // 主按钮 ─ 立即更新
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFFB22222),
                          const Color(0xFFDC3545),
                        ]
                      : [
                          const Color(0xFFC0392B),
                          const Color(0xFFE74C3C),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC3545).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  DownFile.downLoadApk(url: appVersion.downpath);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '立即更新'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 次要按钮 ─ 稍后再说
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () {
                if (Platform.isAndroid) {
                  // 不执行任何操作，保持弹窗可见
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? Colors.white.withOpacity(0.4)
                    : const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '稍后更新'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : const Color(0xFF9CA3AF),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 弹窗入场动画：缩放 + 淡入
class _AnimatedEntry extends StatefulWidget {
  final Widget child;

  const _AnimatedEntry({Key? key, required this.child}) : super(key: key);

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.22, 1.0, 0.36, 1.0), // 弹性缓出
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: 0.85 + (0.15 * _scaleAnimation.value),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
