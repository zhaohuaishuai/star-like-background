import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';

enum ToastStatusEnum {
  error,
  success,
  info,
  warning,
  loading,
}

/// [ToastOverlayEntry] 扩展overlayEnter功能，增加显隐时的动画.
class ToastOverlayEntry {
  String message;
  late OverlayEntry _overlayEntry;
  OverlayEntry get overlayEntry => _overlayEntry;
  ToastOverlayEntry({required this.message}) {
    _overlayEntry = OverlayEntry(builder: builder());
  }
  bool _show = true;
  bool get show => _show;
  set show(bool value) {
    _show = value;
    _overlayEntry.markNeedsBuild();
  }

  WidgetBuilder builder() {
    return (context) {
      TextStyle style = const TextStyle(color: Colors.white);
      TextSpan text = TextSpan(
        text: message,
        style: style,
      );

      TextPainter textPainter = TextPainter(
        text: text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      double textWidth = textPainter.width;
      double height = MediaQuery.of(context).padding.top + 60.0;
      return AnimationToastWidget(
          height: height,
          textWidth: textWidth,
          style: style,
          show: show,
          message: message);
    };
  }

  Future<void> remove() async {
    show = false;
    await Future.delayed(const Duration(milliseconds: 500));
    _overlayEntry.remove();
  }
}

class Item {
  Duration duration;
  OverlayState? overlayState;
  ToastOverlayEntry toastOverlayEntry;
  Completer transitionCompleter;
  late Timer _timer;
  Item(this.toastOverlayEntry, this.overlayState, this.duration,
      this.transitionCompleter);
  show() {
    overlayState?.insert(toastOverlayEntry.overlayEntry);
    _timer = Timer(duration, () {
      hide();
    });
  }

  hide() async {
    await toastOverlayEntry.remove();
    _timer.cancel();
    transitionCompleter.complete();
  }
}

class ToastQueue {
  List<Item> queue = [];
  add(Item item) {
    queue.add(item);
    _check();
  }

  _check() {
    if (queue.isNotEmpty) {
      queue.first.show();
      queue.removeAt(0);
      _check();
    }
  }
}

class Toast {
  static final ToastQueue _queue = ToastQueue();
  static OverlayState? overlayState;
  static List<OverlayEntry> overlayEntries = [];

  static Future<void> showToast(String? message,
      [ToastStatusEnum status = ToastStatusEnum.info,
      Duration duration = const Duration(seconds: 1)]) async {

    if(message == null){
      return;
    }
    switch (status) {
      case ToastStatusEnum.error:
        break;
      case ToastStatusEnum.success:
        break;
      case ToastStatusEnum.info:
        break;
      case ToastStatusEnum.warning:
        break;
      case ToastStatusEnum.loading:
        break;
    }
    overlayState ??= Overlay.of(Get.overlayContext!);
    Completer transitionCompleter = Completer();
    Item item = Item(
        ToastOverlayEntry(
          message: message,
        ),
        overlayState,
        duration,
        transitionCompleter);
    _queue.add(item);
    return transitionCompleter.future;
  }

  static ToastController loading() {
    return ToastController();
  }
}

class AnimationToastWidget extends StatelessWidget {
  AnimationToastWidget({
    super.key,
    required this.height,
    required this.textWidth,
    required this.style,
    required this.message,
    required this.show,
  });
  final bool show;
  final double height;
  final double textWidth;
  final TextStyle style;
  final String message;
  final Tween<double> _tween = Tween<double>(begin: 0.0, end: 1.0);
  final Tween<double> _hideTween = Tween<double>(begin: 1.0, end: 0.0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        curve: Curves.fastOutSlowIn,
        tween: show ? _tween : _hideTween,
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Positioned(
            top: (height * value), //(height / 2 - 40),
            left: MediaQuery.of(context).size.width / 2 -
                ((textWidth + StarThemeData.spacing * 2) / 2),
            child: Opacity(
              opacity: value,
              child: Material(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.all(StarThemeData.spacing),
                  child: Text(
                    message,
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class ToastController {
  int _progress = 0;
  set progress(int value) {
    _progress = value;
    update();
  }

  int get progress => _progress;
  OverlayState? _overlayState;
  double windowWidth = Get.context!.width;
  double windoHeight = Get.context!.height;
  List<OverlayEntry> get _overlayEntrys => Toast.overlayEntries;

  show() {
    _overlayState ??= Overlay.of(Get.overlayContext!);
    close();
    _overlayEntrys.add(_createOverlayEntries());
    _overlayState!.insertAll(_overlayEntrys);
  }

  close() {
    for (var element in _overlayEntrys) {
      element.remove();
    }
    _overlayEntrys.clear();
  }

  update() {
    for (var element in _overlayEntrys) {
      element.markNeedsBuild();
    }
  }

  _createOverlayEntries() {
    return OverlayEntry(
      builder: (context) {
        return Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 12,
                      value: _progress / 100,
                      color: StarThemeData.primaryColor,
                      semanticsLabel: '$_progress%',
                      semanticsValue: _progress.toString(),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  SizedBox(height: StarThemeData.spacing),
                  Text(
                    key: ValueKey(_progress),
                    '$_progress%',
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  )
                ],
              ),
            ),
          ),
        ));
      },
    );
  }
}
