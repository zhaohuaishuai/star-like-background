import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_lyric/lyrics_log.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/data/services/star_player.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/lyric_ui.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/tran.dart';

class LyricWidget extends StatefulWidget {
  final String? lyric; // 歌词
  final String? lrc; // 标准歌词
  final String? assLyric; // 高级歌词
  final Size? size; // 歌词大小
  const LyricWidget(
      {super.key, this.lyric, this.lrc, this.assLyric, this.size});

  @override
  State<LyricWidget> createState() => _LyricWidgetState();
}

class _LyricWidgetState extends State<LyricWidget> {
  StarPlayerAbstract player = StarPlayer.to;

  Stream<Duration?> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<bool> get playingStream => player.playingStream;
  bool playing = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isLRC = false;
  LyricsReaderModel? lyricModel;
  var lyricUI = LyricUI();
  @override
  void initState() {
    super.initState();
    if (widget.lrc != null || widget.assLyric != null) {
      isLRC = true;
      _initLyricModel();
      initEvent();
    }
  }

  void initEvent() {
    durationStream.listen((event) {
      if (mounted) {
        setState(() {
          duration = event ?? Duration.zero;
        });
      }
    });

    playingStream.listen((event) {
      if (mounted) {
        setState(() {
          playing = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLRC) {
      return _lrcBuild(context);
    } else {
      return _lyricBuild(context);
    }
  }

  _initLyricModel() {
    if (widget.assLyric != null) {
      lyricUI.highlight = true;
      // 转换ASS歌词为高级歌词
      final result = convertAssToAdvancedLyric(widget.assLyric!);
      lyricModel =
          LyricsModelBuilder.create().bindLyricToMain(result).getModel();
    } else {
      lyricModel = LyricsModelBuilder.create()
          .bindLyricToMain(sortText(widget.lrc!))
          .getModel();
    }
  }

  @override
  void didUpdateWidget(covariant LyricWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lrc != null && oldWidget.lrc != widget.lrc) {
      isLRC = true;
      _initLyricModel();
      refreshLyric();
      setState(() {});

      return;
    }

    if (widget.lyric != null && oldWidget.lyric != widget.lyric) {
      isLRC = false;
      setState(() {});
    }
  }

  _lrcBuild(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: positionStream,
        builder: (context, snapshot) {
          if (lyricModel == null) return Container();
          var position = Duration.zero;
          if (snapshot.hasData) {
            position = snapshot.data!;
          }
          return LyricsReader(
            padding: EdgeInsets.symmetric(horizontal: StarThemeData.spacing),
            model: lyricModel,
            position: position.inMilliseconds,
            lyricUi: lyricUI,
            playing: playing,
            size: widget.size ??
                Size(double.infinity, MediaQuery.of(context).size.height),
            emptyBuilder: () => Center(
              child: Text(
                '暂无歌词',
                style: lyricUI.getOtherMainTextStyle(),
              ),
            ),
            selectLineBuilder: (progress, confirm) {
              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        LyricsLog.logD('点击事件');
                        confirm.call();
                        setState(() {
                          player.seek(Duration(milliseconds: progress));
                          if (!playing) {
                            player.play();
                          }
                        });
                      },
                      icon: Icon(Icons.play_arrow,
                          color: Theme.of(context).colorScheme.secondary)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary),
                      height: 1,
                      width: double.infinity,
                    ),
                  ),
                  Text(
                    Duration(milliseconds: progress).toString().split('.')[0],
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  _lyricBuild(BuildContext context) {
    if (widget.lyric == null) {
      return const Center(
        child: Text(
          '暂无歌词',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    var lyricList = widget.lyric!.split('\n').map((element) {
      return element;
    }).toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            lyricList[index],
            textAlign: TextAlign.center,
            style: lyricUI.getOtherMainTextStyle(),
          ),
        );
      },
      itemCount: lyricList.length,
    );
  }

// 解析和排序歌词
  String sortText(String text) {
    // 提取每一行歌词
    List<String> lines = text.split('\n');

    // 存储时间戳和歌词的映射
    List<Map<String, dynamic>> allTimestamps = [];

    // 提取每行中的时间戳和歌词
    for (var line in lines) {
      // 提取时间戳部分和歌词部分
      var timePattern = RegExp(r'\[(\d{2}:\d{2}\.\d{2})\]');
      var times =
          timePattern.allMatches(line).map((match) => match.group(1)).toList();
      var lyrics = line.replaceAll(timePattern, '').trim();

      // 将时间戳和歌词作为映射加入列表
      for (var time in times) {
        allTimestamps.add({'timestamp': time, 'text': lyrics});
      }
    }

    // 对时间戳进行排序
    allTimestamps.sort((a, b) {
      List<int> timeA = _parseTime(a['timestamp']!);
      List<int> timeB = _parseTime(b['timestamp']!);
      return (timeA[0] * 60 + timeA[1]).compareTo(timeB[0] * 60 + timeB[1]);
    });

    // 返回排序后的歌词
    return allTimestamps
        .map((entry) => "[${entry['timestamp']}]${entry['text']}")
        .toList()
        .join('\n');
  }

// 解析时间戳（"mm:ss.xx"）为分钟和秒数的列表
  List<int> _parseTime(String timestamp) {
    List<String> parts = timestamp.split(':');
    int minutes = int.parse(parts[0]);
    double seconds = double.parse(parts[1]);
    int sec = seconds.toInt();
    return [minutes, sec];
  }

  void refreshLyric() {
    lyricUI = LyricUI.clone(lyricUI);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
