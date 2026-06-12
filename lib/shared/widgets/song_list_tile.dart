import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/data/module/sgb_data.dart';

class SongListTile extends StatelessWidget {
  final SgbData song;
  final Function onTap;
  final bool? playing;
  final bool? selected;
  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.playing,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    Widget? playingWidget;
    if (playing == true && selected == true) {
      playingWidget = const PlayingWidget(
        playing: true,
      );
    } else if (playing == false && selected == true) {
      playingWidget = const PlayingWidget(
        playing: false,
      );
    }

    return ListTile(
        leading: Text('${song.xuhao}'),
        title: Text(song.title),
        trailing: playingWidget,
        onTap: () => onTap(song));
  }
}

class PlayingWidget extends StatefulWidget {
  final bool? playing;
  const PlayingWidget({super.key, this.playing});

  @override
  State<PlayingWidget> createState() => _PlayingWidgetState();
}

class _PlayingWidgetState extends State<PlayingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(
      reverse: true,
    ); // 设置动画循环
    if (widget.playing == true) {
      // _controller.forward();
    } else {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant PlayingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.playing != oldWidget.playing) {
      if (widget.playing == true) {
        _controller.forward();
      } else {
        _controller.reverse(from: _controller.value);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = context.isDarkMode ? const Color(0xFFEE8765) : Colors.grey[600]!;

    return SizedBox(
      width: 36,
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 6,
                  height: 20 * (widget.playing ?? false ? _animation.value : 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
          const Spacer(),
          AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 6,
                  height:
                      30 * (widget.playing ?? false ? 1 - _animation.value : 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
          const Spacer(),
          AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 6,
                  height: 20 * (widget.playing ?? false ? _animation.value : 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              })
        ],
      ),
    );
  }
}
