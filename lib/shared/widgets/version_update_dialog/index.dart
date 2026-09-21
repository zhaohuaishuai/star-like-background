import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/utils/down_file.dart';
import 'package:m/data/module/app_version.dart';

/// 版本更新弹窗组件
///
/// 设计说明：
/// 以设计好的 `assets/img/app_update.jpg`（暖白米色 + 金色装饰的竖版海报）
/// 作为整张背景图，在图片上方叠加展示「版本号」「更新内容」与「立即更新」按钮。
/// 弹窗宽高比与背景图保持一致，文字采用深棕暖色系，与金色装饰统一。
class VersionUpdateDialog extends StatelessWidget {
  final AppVersion appVersion;

  const VersionUpdateDialog({
    super.key,
    required this.appVersion,
  });

  /// 背景图宽高比（1463 / 1986），用于保证弹窗比例与图片一致
  static const double _imageRatio = 1463 / 1986;

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
    final screenWidth = MediaQuery.of(context).size.width;
    // 弹窗宽度：最大 320，并适配小屏留出边距
    final dialogWidth = (screenWidth - 56).clamp(240.0, 320.0).toDouble();
    final dialogHeight = dialogWidth / _imageRatio;

    return PopScope(
      canPop: false,
      child: Center(
        child: SingleChildScrollView(
          child: _AnimatedEntry(
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB8860B).withOpacity(0.3),
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
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景图铺满整个弹窗
                  Image.asset(
                    'assets/img/app_update.jpg',
                    fit: BoxFit.fill,
                  ),
                  // 内容层：在背景图上叠加版本、更新内容与按钮
                  _buildContent(dialogHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 在背景图上叠加版本号、更新内容与「立即更新」按钮
  Widget _buildContent(double dialogHeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26, dialogHeight * 0.24, 26, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 版本号徽章（位于图片顶部装饰图案下方，下移 4 像素）
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(child: _buildVersionBadge()),
          ),
          SizedBox(height: dialogHeight * 0.04),
          // 更新内容（可滚动，宽度收窄居中）
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.86,
                child: _buildContextScroll(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 立即更新按钮（尺寸缩小，居中）
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.78,
              child: _buildUpdateButton(),
            ),
          ),
        ],
      ),
    );
  }

  /// 版本号徽章：金色描边 + 深棕文字
  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFB8860B).withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB8860B).withOpacity(0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: Color(0xFF8B6914),
          ),
          const SizedBox(width: 6),
          Text(
            'v ${appVersion.version}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B4E1B),
              letterSpacing: 1,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  /// 更新内容滚动区域
  Widget _buildContextScroll() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB8860B).withOpacity(0.18),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '更新内容'.tr,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB8860B),
                letterSpacing: 2,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              appVersion.context,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF4A3B2A),
                letterSpacing: 0.3,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部「立即更新」按钮：暖金棕渐变
  Widget _buildUpdateButton() {
    return SizedBox(
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B5E34),
              Color(0xFFC89B3C),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB8860B).withOpacity(0.4),
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
                '马上升级'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 弹窗入场动画：缩放 + 淡入
class _AnimatedEntry extends StatefulWidget {
  final Widget child;

  const _AnimatedEntry({required this.child});

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
      curve: const Cubic(0.22, 1.0, 0.36, 1.0),
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
