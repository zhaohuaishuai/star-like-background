import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:m/core/constants/constants.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/shared/widgets/anim_huxi_widget/index.dart';

class PlayCircle extends StatefulWidget {
  final bool isPlay;
  final bool breathe;
  final void Function()? onTap;
  final void Function()? onPressed;
  final bool? pageHide;
  final double size;
  const PlayCircle({
    super.key,
    required this.isPlay,
    required this.breathe,
    this.onTap,
    this.onPressed,
    this.pageHide,
    this.size = 360.0,
  });

  @override
  State<PlayCircle> createState() => _PlayCircleState();
}

class _PlayCircleState extends State<PlayCircle> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if(!kIsWeb && Platform.isIOS){
    //   return PlayCircleWidget(isPlay: widget.isPlay,onTap: widget.onTap,);
    // }
    final size = widget.size;
    return SizedBox(
      height: size * 1.03,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          widget.breathe
              ? AnimHuxiWidget(
                  size: size * 0.8,
                  pageHide: widget.pageHide,
                  onClose: () => widget.onPressed?.call(),
                )
              : PlayCircleWidget(
                  isPlay: widget.isPlay,
                  onTap: widget.onTap,
                  size: size,
                ),
          !widget.breathe
              ? Positioned(
                  // top:0,left:StarThemeData.spacing,
                  bottom: 0,
                  child: TextButton(
                    onPressed: () {
                      widget.onPressed?.call();
                    },
                    child: Text(
                      '呼吸模式'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class PlayCircleWidget extends StatefulWidget {
  final bool isPlay;
  final void Function()? onTap;
  final double size;
  const PlayCircleWidget({
    super.key,
    required this.isPlay,
    required this.size,
    this.onTap,
  });

  @override
  State<PlayCircleWidget> createState() => _PlayCircleWidgetState();
}

class _PlayCircleWidgetState extends State<PlayCircleWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late AnimationController _animationController2;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 160),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation2 =
        Tween<double>(begin: 0.83, end: 0.89).animate(_animationController2);

    if (widget.isPlay) {
      _animationController.repeat();
      _animationController2.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selfSize = widget.size * .76;
    return SizedBox(
      height: widget.size,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 60,
            child: RotationTransition(
              turns: _animation,
              child: InkWell(
                onTap: widget.onTap,
                child: Container(
                  height: selfSize,
                  width: selfSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(selfSize / 2),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final size = constraints.maxWidth;
                    final msize = size * .68;
                    final mmsize = msize * .95;
                    debugPrint('size:$size');
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                            height: size,
                            width: size,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(size / 2),
                            )),
                        Container(
                          height: size,
                          width: size,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(size / 2),
                            gradient: RadialGradient(
                                tileMode: TileMode.repeated,
                                stops: const [0.0, 0.5, 1], // 控制渐变的分布
                                radius: 0.01,
                                center: Alignment.center,
                                colors: [
                                  Colors.black,
                                  Colors.grey.withOpacity(0.1),
                                  Colors.black,
                                ]),
                          ),
                        ),
                        sweepGradientBuilder(math.pi, math.pi * 1.2, size),
                        sweepGradientBuilder(math.pi * 0, math.pi * 0.2, size),
                        Container(
                          width: msize,
                          height: msize,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(msize / 2)),
                        ),
                        Container(
                          width: mmsize,
                          height: mmsize,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(mmsize / 2)),
                          child: ClipOval(
                              child: Image.network(
                            StarThemeData.coverUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.topLeft,
                          )),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            height: 146,
            width: 10,
            child: Stack(
              // alignment: Alignment.topCenter,
              children: [
                RotationTransition(
                  turns: _animation2,
                  alignment: const Alignment(0, -.8),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0XFFF8F8F8),
                        borderRadius: BorderRadius.circular(18)),
                    child: Align(
                      alignment: const Alignment(0, -.90),
                      child: Container(
                        transformAlignment: Alignment.topCenter,
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container sweepGradientBuilder(
      double startAngle, double endAngle, double size) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        gradient: SweepGradient(
            startAngle: startAngle,
            endAngle: endAngle,
            stops: const [
              0.0,
              0.5,
              0.6,
              1
            ], // 控制渐变的分布
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.0)
            ]),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PlayCircleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlay) {
      _animationController.repeat();
      _animationController2.forward();
    } else {
      _animationController.stop();
      _animationController2.reverse(from: _animationController2.value);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    super.dispose();
  }
}
