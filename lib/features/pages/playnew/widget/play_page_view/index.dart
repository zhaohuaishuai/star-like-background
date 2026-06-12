import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/module/audio_source_tag.dart';
import 'package:m/data/services/star_player.dart';
import 'package:m/data/services/user.dart';
import 'package:m/features/pages/playnew/controller.dart';
import 'package:m/features/pages/playnew/widget/play_circle/index.dart';
import 'package:m/features/pages/playnew/widget/play_gepu/index.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/index.dart';
import 'dart:math' as math;

double paddintTop = 36;
bool oldIsPlaying = false;

// ignore: must_be_immutable
class PlayPageView extends StatefulWidget {
  void Function()? onTab;
  void Function()? onToGePu;
  void Function()? onSwitchBreathe;
  bool? pageHide;
  bool breathe;
  PlayPageView(
      {super.key,
      this.onTab,
      required this.breathe,
      this.onSwitchBreathe,
      this.pageHide});

  @override
  State<PlayPageView> createState() => _PlayPageViewState();
}

class _PlayPageViewState extends State<PlayPageView>
    with AutomaticKeepAliveClientMixin {
  PageController pageController = PageController(initialPage: 1);

  PlayNewController playNewController = Get.put(PlayNewController());

  StarPlayerAbstract get ads => StarPlayer.to;

  AudioSource palyerAudioSource = StarPlayer.to.palyerAudioSource;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _playBuilder(context);
  }

  Container _playBuilder(BuildContext context) {
    Color iconColor = !context.isDarkMode
        ? Colors.black.withOpacity(0.6)
        : Colors.white.withOpacity(0.6);
    return Container(
        padding: EdgeInsets.only(bottom: StarThemeData.spacing),
        child: Container(
          alignment: Alignment.center,
          // decoration: BoxDecoration( color: Colors.black.withOpacity(0.1)),
          child: Obx(() => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ads.currentSong.value?.dmtUrl.banZouUrl != ''
                      ? CupertinoSegmentedControl(
                          unselectedColor: Colors.white,
                          selectedColor: StarThemeData.primaryColor,
                          borderColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: StarThemeData.spacing),
                          groupValue: ads.playTarget.value.index,
                          children: {
                            PlayTargetEnum.yuanChang.index: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: StarThemeData.spacing),
                              child: const Text('原唱'),
                            ),
                            PlayTargetEnum.banZou.index: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: StarThemeData.spacing),
                              child: const Text('伴奏'),
                            ),
                          },
                          onValueChanged: (value) {
                            ads.playTarget.value = PlayTargetEnum.values[value];
                            ads.switchPlayTarget(ads.playTarget.value);
                          })
                      : const SizedBox(),

                  _buildCircle(),
                  // Expanded(child: Container()),
                  _favoriteBuilder(iconColor),
                  // Padding(padding: EdgeInsets.only(top: StarThemeData.spacing)),
                  StreamBuilder<Duration?>(
                      stream: ads.durationStream,
                      builder: (context, snapshot) {
                        return StreamBuilder(
                          stream: ads.positionStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError || snapshot.data == null) {
                              return Container();
                            }

                            final position = snapshot.data ?? Duration.zero;
                            final duration = ads.duration ?? Duration.zero;

                            // position 转成 00:00:00 格式
                            String positionStr =
                                position.toString().split('.')[0];
                            String durationStr =
                                duration.toString().split('.')[0];
                            return Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Slider(
                                    value: position.inMilliseconds.toDouble(),
                                    min: 0,
                                    max: duration.inMilliseconds.toDouble(),
                                    onChanged: (value) {
                                      ads.seek(Duration(
                                          milliseconds: value.toInt()));
                                    },
                                    onChangeStart: (value) {
                                      oldIsPlaying = ads.playing;
                                      ads.pause();
                                    },
                                    onChangeEnd: (value) {
                                      if (oldIsPlaying) {
                                        ads.play();
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: StarThemeData.spacing * 2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        positionStr,
                                      ),
                                      Text(durationStr),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      }),
                  _buildBottom(context, iconColor),
                ],
              )),
        ));
  }

  Widget _buildCircle() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ads.playTarget.value == PlayTargetEnum.banZou) {
            return LyricWidget(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              lyric: ads.currentSong.value?.dmtUrl.lyric,
              lrc: ads.currentSong.value?.dmtUrl.lrc,
              assLyric: ads.currentSong.value?.dmtUrl.assLyric,
            );
          }

          return StreamBuilder<bool>(
            stream: ads.playingStream,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                final height = math.min(constraints.maxWidth, 420.0);
                return PlayCircle(
                  size: height,
                  breathe: widget.breathe,
                  onPressed: widget.onSwitchBreathe,
                  pageHide: widget.pageHide,
                  onTap: () {
                    widget.onTab?.call();
                  },
                  isPlay: snapshot.data ?? false,
                );
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  Widget _favoriteBuilder(Color iconColor) {
    bool isFavorite = false;
    // 无论是否登录，都检查收藏列表（后端通过 fingerprintId 或 userId 匹配）
    if (UserService.to.shouCang?.list != null &&
        UserService.to.shouCang!.list!.isNotEmpty) {
      isFavorite = UserService.to.shouCang!.list!
          .contains(ads.currentSong.value?.id ?? '');
    }

    IconData iconData =
        isFavorite ? Icons.favorite : Icons.favorite_border_outlined;
    bool isThereNoDataUsageRequired = false;
    if (palyerAudioSource.sequence.isNotEmpty) {
      AudioSourceTag? song =
          palyerAudioSource.sequence.first.tag as AudioSourceTag?;
      debugPrint('tag ${song?.source}');
      isThereNoDataUsageRequired = song?.source == SourceEnum.local;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: StarThemeData.spacing * 2,
        right: StarThemeData.spacing * 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 240,
                    child: Text(
                      ads.currentSong.value?.fullTitle ?? '',
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  isThereNoDataUsageRequired
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('免流量'.tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              )),
                        )
                      : Container(),
                ],
              ),
              Text(
                ads.currentSong.value?.shijiname ?? '',
              ),
            ],
          ),
          IconButton(
              onPressed: () async {
                // 尚未加载到收藏歌单，先尝试获取
                if (UserService.to.shouCang == null) {
                  await UserService.to.getShouCang();
                }
                if (UserService.to.shouCang == null) {
                  Toast.showToast('收藏功能不可用'.tr);
                  return;
                }
                if (isFavorite) {
                  await UserService.to.delSongListItem(
                      UserService.to.shouCang!.id,
                      ads.currentSong.value?.id ?? '');
                } else {
                  await UserService.to.addSongListItem(
                      UserService.to.shouCang!.id, ads.currentSong.value!.id);
                }
                await UserService.to.getShouCang();
              },
              icon: Icon(iconData, fill: 1, size: 40, color: Colors.red)),
        ],
      ),
    );
  }

  StreamBuilder _buildBottom(BuildContext context, Color iconColor) {
    return StreamBuilder<bool>(
      stream: ads.playingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container();
        }
        String? adUrl = ads.currentSong.value?.dmtUrl.adUrl;
        String? enGePuUrl = ads.currentSong.value?.dmtUrl.enGePuUrl;
        bool isAd = adUrl != null && adUrl.isNotEmpty;
        Widget enPuWidget = TextButton.icon(
            label: Text(
              'En谱',
              style: TextStyle(color: iconColor, fontSize: 16),
            ),
            onPressed: () {
              Get.to(PlayGePuWidget(isShow: true, url: enGePuUrl));
            });
        List<Widget> bottomWidget = [
          IconButton(
            icon: Icon(
              Icons.playlist_add,
              size: 30,
              color: iconColor,
            ),
            onPressed: () {
              if (!UserService.to.isLogin) {
                UserService.to.showLoginDialog();
                return;
              }
              UserService.to
                  .showAddSongListBotomSheet(song: ads.currentSong.value);
            },
          ),
          IconButton(
              onPressed: () {
                if (ads.currentSong.value == null) {
                  return;
                }
                StarPlayer.to.shareAudioFile(
                    title: '下载文件:${ads.currentSong.value!.fullTitle}');
              },
              icon: Icon(Icons.download, size: 30, color: iconColor)),
          IconButton(
              onPressed: () async {
                if (ads.currentSong.value == null) {
                  return;
                }
                await Utils.copyText(ads.currentSong.value!.dmtUrl.lyric ?? '');
                Toast.showToast('歌词复制成功');
              },
              icon: Icon(Icons.copy, size: 30, color: iconColor)),
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
              color: iconColor,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.search);
            },
          ),
          // 设置播放器倒计时停止功能
          IconButton(
              onPressed: () {
                _showSleepTimerDialog();
              },
              icon: Icon(Icons.timer_outlined, size: 30, color: iconColor)),
        ];

        if (enGePuUrl != null && enGePuUrl.isNotEmpty) {
          bottomWidget.insert(3, enPuWidget);
        }
        return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: StarThemeData.spacing, vertical: 0),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () {
                      IconData iconData = ads.playMode.value.icon;
                      return IconButton(
                          onPressed: () {
                            ads.changePlayMode();
                          },
                          icon: Icon(iconData,
                              // IconUtil.wuXiang,
                              color: iconColor,
                              size: 28));
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        ads.previous();
                      },
                      icon: Icon(Icons.skip_previous_rounded,
                          color: iconColor, size: 64)),
                  IconButton(
                      onPressed: () {
                        if (!isAd) {
                          return;
                        }
                        if (ads.playing) {
                          ads.pause();
                        } else {
                          ads.play();
                        }
                      },
                      icon: Icon(
                          !isAd
                              ? Icons.block
                              : snapshot.data!
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                          color: iconColor,
                          size: 84)),
                  IconButton(
                      onPressed: () {
                        ads.next();
                      },
                      icon: Icon(Icons.skip_next_rounded,
                          color: iconColor, size: 64)),
                  IconButton(
                      onPressed: () {
                        ads.showBottomSheet();
                      },
                      icon:
                          Icon(Icons.playlist_play, color: iconColor, size: 32))
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: bottomWidget),
            ]));
      },
    );
  }

  onPageChanged(int value) {
    debugPrint('value: $value');
    Duration duration = const Duration(milliseconds: 680);
    if (value == 4) {
      Future.delayed(duration, () => pageController.jumpToPage(1));
    } else if (value == 0) {
      Future.delayed(duration, () => pageController.jumpToPage(3));
    }
  }

  /// 显示睡眠定时器选择对话框
  void _showSleepTimerDialog() {
    int customMinutes = 30; // 默认值
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('定时停止播放'.tr,
              style: TextStyle(color: Theme.of(context).primaryColor)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 预设时间选项
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _buildTimeChip('15分钟', 15, setState),
                        _buildTimeChip('30分钟', 30, setState),
                        _buildTimeChip('45分钟', 45, setState),
                        _buildTimeChip('1小时', 60, setState),
                        _buildTimeChip('2小时', 120, setState),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('滑动选择: $customMinutes 分钟',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    Slider(
                      value: customMinutes.toDouble(),
                      min: 1,
                      max: 240, // 最大4小时
                      divisions: 239,
                      label: '${customMinutes.round()}分钟',
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        setState(() {
                          customMinutes = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // 确认和取消按钮（仅在定时器激活时显示取消按钮）
                    Row(
                      children: [
                        if (ads.isSleepTimerActive) ...[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                ads.cancelSleepTimer(); // 取消定时
                              },
                              child: Text('取消定时'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if (customMinutes > 0) {
                                Navigator.of(context).pop();
                                ads.setSleepTimer(customMinutes);
                              }
                            },
                            child:
                                Text(ads.isSleepTimerActive ? '重新设置' : '确认定时'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 构建时间选择芯片
  Widget _buildTimeChip(String label, int minutes, StateSetter setState) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        Navigator.of(context).pop();
        ads.setSleepTimer(minutes);
      },
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      side: BorderSide(color: Theme.of(context).primaryColor),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
