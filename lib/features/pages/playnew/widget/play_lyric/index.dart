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
    if ((widget.lrc != null && widget.lrc!.isNotEmpty) ||
        widget.assLyric != null) {
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
    if (widget.lrc != null &&
        widget.lrc!.isNotEmpty &&
        oldWidget.lrc != widget.lrc) {
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

  /// 解析和排序歌词
  /// 将多时间戳行展开为单行，按时间排序，并将百分秒转换为毫秒格式
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

    // 使用毫秒精度进行排序，确保同秒内的多时间戳顺序正确
    allTimestamps.sort((a, b) {
      return _parseTimestampToMs(a['timestamp']!)
          .compareTo(_parseTimestampToMs(b['timestamp']!));
    });

    // 将百分秒时间戳转换为毫秒格式，适配 flutter_lyric 的解析逻辑
    // LRC 标准 [mm:ss.xx] 中 xx 是百分秒（1/100秒），
    // 但 flutter_lyric 的 ParserLrc 将其当作毫秒解析，
    // 因此需将 xx * 10 转换为正确的毫秒值输出
    var sortedLyrics = allTimestamps
        .map((entry) =>
            "[${_centisecondsToMilliseconds(entry['timestamp']!)}]${entry['text']}")
        .toList()
        .join('\n');
    // 在歌词开头插入一个空行占位，时间范围为 [0, 首行实际开始时间)
    // 解决 flutter_lyric 的 getCurrentLine 在 progress=0 时默认选中第一行的问题
    return '[00:00.000]\n$sortedLyrics';
  }

  /// 将百分秒格式 [mm:ss.xx] 转换为毫秒格式 [mm:ss.xxx]
  /// 例如：[00:08.48] → [00:08.480]
  String _centisecondsToMilliseconds(String timestamp) {
    final parts = timestamp.split('.');
    if (parts.length != 2) return timestamp;
    // 取前2位百分秒，乘以10转为毫秒
    final centiseconds = int.parse(parts[1].padRight(2, '0').substring(0, 2));
    final ms = (centiseconds * 10).toString().padLeft(3, '0');
    return '${parts[0]}.$ms';
  }

  /// 将时间戳 [mm:ss.xx] 解析为毫秒数，用于精确排序
  int _parseTimestampToMs(String timestamp) {
    final parts = timestamp.split(':');
    final minutes = int.parse(parts[0]);
    final secParts = parts[1].split('.');
    final seconds = int.parse(secParts[0]);
    final centiseconds = secParts.length > 1
        ? int.parse(secParts[1].padRight(2, '0').substring(0, 2))
        : 0;
    return (minutes * 60 + seconds) * 1000 + centiseconds * 10;
  }

  void refreshLyric() {
    lyricUI = LyricUI.clone(lyricUI);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
