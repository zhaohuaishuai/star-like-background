import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/theme/theme_data.dart';

import 'package:m/data/module/song.dart';
import 'package:m/data/services/star_player.dart';

// ignore: must_be_immutable
class MiniPlayer extends GetWidget {
  MiniPlayer({
    super.key,
  });

  StarPlayerAbstract starPlayer = StarPlayer.to;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: StarThemeData.spacing),
        child: Container(
          height: StarThemeData.miniPlayerHeight,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(StarThemeData.miniPlayerHeight / 2),
            color: isDarkMode ? Colors.black : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Row(children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.playnew);
                  },
                  child: ClipOval(
                    child: Container(
                      width: StarThemeData.miniPlayerHeight,
                      height: StarThemeData.miniPlayerHeight,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: ClipOval(
                          child: Image.network(
                        StarThemeData.coverUrl,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          return Container(
                            color: StarThemeData.loadingTextColor,
                            child: child,
                          );
                        },
                      )),
                    ),
                  ),
                ),
                SizedBox(width: StarThemeData.spacing),
                Expanded(
                  child: Obx(() {
                    Song? song = starPlayer.currentSong.value;
                    return Text(
                      song?.fullTitle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    );
                  }),
                ),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StreamBuilder(
                    stream: starPlayer.playingStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return IconButton(
                            onPressed: () {
                              snapshot.data!
                                  ? starPlayer.pause()
                                  : starPlayer.play();
                            },
                            icon: Icon(snapshot.data!
                                ? Icons.pause
                                : Icons.play_arrow));
                      }

                      return Container();
                    }),
                IconButton(
                    onPressed: () {
                      starPlayer.showBottomSheet();
                    },
                    icon: const Icon(Icons.menu_rounded))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
