import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/theme/theme_data.dart';

import 'package:m/features/pages/playnew/controller.dart';
import 'package:m/features/pages/playnew/widget/play_gepu/index.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/index.dart';
import 'widget/play_page_view/index.dart';

double paddintTop = 36;

// ignore: must_be_immutable
class PlayNewPage extends GetWidget<PlayNewController> {
  const PlayNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: [
          //毛玻璃质的背景
          Container(
            decoration: BoxDecoration(
              gradient: context.isDarkMode
                  ? StarThemeData.darkPlayGradient
                  : StarThemeData.playGradient,
              image: DecorationImage(
                  opacity: 0.3,
                  image: Image.network(playCoverUrl).image,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 16),
            child: Padding(
                padding: EdgeInsets.only(
                    top: paddingTop + StarThemeData.spacing + paddingTop),
                child: Obx(() => PageView(
                      controller: controller.lyricController,
                      physics: controller.physics,
                      onPageChanged: (value) => controller.changePage(value),
                      children: [
                        Obx(() => Center(
                              child: PlayGePuWidget(
                                isShow: controller.currentLyricIndex.value == 0,
                                url: controller.gepuUrl,
                              ),
                            )),
                        Center(
                          child: Obx(() => PlayPageView(
                                pageHide: controller.pageHide,
                                breathe: controller.breathe.value,
                                onSwitchBreathe: () {
                                  controller.breathe.value =
                                      !controller.breathe.value;
                                },
                              )),
                        ),
                        Obx(() => LyricWidget(
                              lyric: controller.lyric,
                              lrc: controller.lrc,
                              assLyric: controller.assLyric,
                            ))
                      ],
                    ))),
          ),

          Positioned(
            top: paddingTop,
            left: 0,
            right: 0,
            height: 48,
            child: Align(
              alignment: Alignment.center,
              child: _selectPageBuilder(context),
            ),
          )
        ],
      ),
    );
  }

  _selectPageBuilder(BuildContext context) {
    Color iconColor = !context.isDarkMode
        ? Colors.black.withOpacity(0.6)
        : Colors.white.withOpacity(0.6);
    TextStyle style = const TextStyle(color: Colors.white, fontSize: 12);
    Color color = context.isDarkMode
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 30,
              color: iconColor,
            ),
            onPressed: () {
              Get.back();
            }),
        const Spacer(),
        Container(
            width: 250,
            height: 38,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color,
            ),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: controller.currentLyricIndex.value == 0
                            ? WidgetStateProperty.all(
                                Theme.of(context).primaryColor.withOpacity(0.4))
                            : null),
                    autofocus: true,
                    onPressed: () {
                      controller.lyricController.animateToPage(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '歌谱'.tr,
                        style: style,
                      ),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: controller.currentLyricIndex.value == 1
                            ? WidgetStateProperty.all(
                                Theme.of(context).primaryColor.withOpacity(0.4))
                            : null),
                    onPressed: () {
                      controller.lyricController.animateToPage(1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: Text('播放器'.tr, style: style),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: controller.currentLyricIndex.value == 2
                            ? WidgetStateProperty.all(
                                Theme.of(context).primaryColor.withOpacity(0.4))
                            : null),
                    onPressed: () {
                      controller.lyricController.animateToPage(2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: Text(
                      '歌词'.tr,
                      style: style,
                    ),
                  ),
                ],
              ),
            )),
        const Spacer(),
        PopupMenuButton(
            icon: Icon(
              Icons.share_outlined,
              size: 30,
              color: iconColor,
            ),
            onSelected: (value) {
              if (value == 1) {
                controller.shareUrl();
              } else if (value == 2) {
                controller.shareGePuFile();
              } else if (value == 3) {
                controller.shareAudioFile();
              } else if (value == 4) {
                controller.shareLyric();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: StarPopupMenuButton(icon: Icons.web, text: '分享链接'.tr),
                ),
                PopupMenuItem(
                  value: 2,
                  child: StarPopupMenuButton(
                      icon: Icons.library_music, text: '分享歌谱'.tr),
                ),
                PopupMenuItem(
                  value: 3,
                  child: StarPopupMenuButton(
                      icon: Icons.music_note_outlined, text: '分享音频'.tr),
                ),
                PopupMenuItem(
                  value: 4,
                  child: StarPopupMenuButton(
                      icon: Icons.format_list_numbered_outlined,
                      text: '分享歌词'.tr),
                ),
              ];
            }),
      ],
    );
  }
}

class StarPopupMenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  const StarPopupMenuButton({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: StarThemeData.primaryColor,
        ),
        SizedBox(width: StarThemeData.spacing),
        Text(
          text,
          style: TextStyle(color: StarThemeData.primaryColor),
        )
      ],
    );
  }
}
