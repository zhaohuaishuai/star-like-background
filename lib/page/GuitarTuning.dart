import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../container/Tune.dart';
import '../widget/StarScaffold.dart';
import '../widget/InnerGlowContainer.dart';

// 在标准调弦下，吉他各弦空弦发音的频率如下：
// 第 1 弦：E，频率为 329.63 Hz
// 第 2 弦：B，频率为 246.94 Hz
// 第 3 弦：G，频率为 196.00 Hz
// 第 4 弦：D，频率为 146.83 Hz
// 第 5 弦：A，频率为 110.00 Hz
// 第 6 弦：E，频率为 82.41 Hz
// 这些频率是基于 A4 = 440 Hz 的标准音高设定。这也是最常用的音高设定，被许多吉他调音器默认使用。

class GuitarTuning extends GetView<Tune> {
  GuitarTuning({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StarScaffold(
      actions: [
        Obx(() {
          return TextButton.icon(
              label: Text(
                controller.isRecored.value ? '结束调音' : '开始调音',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                controller.isRecored.value
                    ? Icons.stop_circle
                    : Icons.play_circle_fill,
                size: 24,
                color: Colors.white,
              ),
              onPressed: () {
                if (controller.isRecored.value) {
                  controller.stopRecording();
                } else {
                  controller.startRecording();
                }
              });
        }),
      ],
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Obx(() => Text(controller.note.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
              ))),
          SizedBox(
            height: 20,
          ),
          Obx(() {
            double targetValue = controller.turnStatus.value ==
                    "TuningStatus.waytoolow"
                ? -0.5
                : controller.turnStatus.value == "TuningStatus.toolow"
                    ? -0.25
                    : controller.turnStatus.value == "TuningStatus.tuned"
                        ? 0
                        : controller.turnStatus.value == "TuningStatus.toohigh"
                            ? 0.25
                            : controller.turnStatus.value ==
                                    "TuningStatus.waytoohigh"
                                ? 0.5
                                : 0;
            return CursorWidght(targetValue: targetValue);
          }),
          Obx(() {
            return Text(
              controller.curPitch.value.toStringAsFixed(2),
              style: TextStyle(color: Colors.white, fontSize: 24),
            );
          }),
          Obx(() => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 250,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            NoteChess(
                                note: "D", actived: controller.note == "D"),
                            SizedBox(
                              height: 26,
                            ),
                            NoteChess(
                                note: "A", actived: controller.note == "A"),
                            SizedBox(
                              height: 24,
                            ),
                            NoteChess(
                                note: "E",
                                actived: controller.note == "E" &&
                                    controller.curPitch < 100),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Container(
                        child: Center(
                            child: Opacity(
                                opacity: 0.5,
                                child: Image.asset(
                                    "assets/images/guitar_headstock.png"))),
                      )),
                      Container(
                        width: 50,
                        height: 260,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            NoteChess(
                              note: "G",
                              actived: controller.note == "G",
                            ),
                            SizedBox(
                              height: 26,
                            ),
                            NoteChess(
                              note: "B",
                              actived: controller.note == "B",
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            NoteChess(
                              note: "E",
                              actived: controller.note == "E" &&
                                  controller.curPitch > 300,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class CursorWidght extends StatelessWidget {
  final double targetValue;
  CursorWidght({Key? key, required this.targetValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: targetValue),
      builder: (context, value, child) {
        // print("value-->$value");
        return Stack(
          alignment: Alignment(value, -1.1),
          children: [
            Container(
              height: 300,
              child: Row(children: [
                Spacer(),
                Container(
                  width: 1,
                  height: 230,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            0.0,
                            0.4,
                            0.6,
                            1.0
                          ],
                          colors: [
                            Colors.black12,
                            Colors.black26,
                            Colors.black26,
                            Colors.black12,
                          ])),
                ),
                Spacer(),
              ]),
            ),
            Opacity(
              opacity: 0.6,
              child: Container(
                width: 50,
                height: 38,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/RUNOOB-SVG-IMAGE.png'),
                        fit: BoxFit.contain)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NoteChess extends StatelessWidget {
  final String note;
  final bool actived;
  NoteChess({
    Key? key,
    required this.note,
    required this.actived,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InnerGlowContainer(
      blurRadius: 40,
      borderRadius: 40,
      color: actived ? Colors.indigo : Colors.white38,
      spreadRadius: 2.3,
      offset: Offset(0, 0),
      child: Container(
        child: Center(
            child: Text(note,
                style: TextStyle(fontSize: 26, color: Colors.white))),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            // color: actived ? Colors.indigo : Colors.transparent,
            // shape: BoxShape.circle,
            // border: Border.all(
            //   color: Colors.indigo, // 边框颜色
            //   width: 2.0, // 边框宽度
            // ),
            ),
      ),
    );
  }
}
