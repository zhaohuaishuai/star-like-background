import 'dart:math';
import 'package:flutter/material.dart';

class PubScaffold extends StatefulWidget {
  final Widget child;
  PubScaffold({ Key? key,required this.child }):super(key: key);
  @override
  _PubScaffoldState createState() => _PubScaffoldState();
}

class _PubScaffoldState extends State<PubScaffold> {
  OverlayEntry _overlayEntry = OverlayEntry(builder: (context)=>Text(""));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    

  }
  bool draggable = false;
  //静止状态下的offset
  Offset idleOffset = Offset(0, 0);
  //本次移动的offset
  Offset moveOffset = Offset(0, 0);
  //最后一次down事件的offset
  Offset lastStartOffset = Offset(0, 0);
  int count = 0;
  // 是否展示呼吸球
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _overlayEntry = OverlayEntry(builder: (context) {
          final size = MediaQuery.of(context).size;
          return Positioned(
            top: draggable ? moveOffset.dy : size.height - 102,
            left: draggable ? moveOffset.dx : size.width - 72,
            child: GestureDetector(
              // 移动开始
              onPanStart: (DragStartDetails details) {
                setState(() {
                  lastStartOffset = details.globalPosition;
                  draggable = true;
                });
                if (count <= 1) {
                  count++;
                }
              },
              // 移动中
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  moveOffset =
                      details.globalPosition - lastStartOffset + idleOffset;
                  if (count > 1) {
                    moveOffset = Offset(max(0, moveOffset.dx), moveOffset.dy);
                  } else {
                    moveOffset = Offset(max(0, moveOffset.dx + (size.width - 72)),
                        moveOffset.dy + (size.height - 102));
                  }
                });
              },
              // 移动结束
              onPanEnd: (DragEndDetails detail) {
                setState(() {
                  idleOffset = moveOffset * 1;
                });
              },
              child: TestContainer(),
            ),
          );
        });
        // 显示悬浮按钮
        // WidgetsBinding.instance
        //     .addPostFrameCallback((_) => Overlay.of(context)!.insert(_overlayEntry));
        return InkWell(
          onTap: (){
            if(!show){
              insertOverlay(context);
              setState(() {
                show = true;
              });
            }else {
              _overlayEntry.remove();
              setState(() {
                show = false;
              });
            }

          },
          child: widget.child,
        ) ;
      },
    );
  }
  // 悬浮按钮，可以拖拽（可自定义样式）
  void insertOverlay(BuildContext context) {
    return Overlay.of(context)!.insert(_overlayEntry);
  }
  void removeOverlay(BuildContext context){
    _overlayEntry.remove();
  }
 
}

// 悬浮按钮的样式
class TestContainer extends StatelessWidget {
  final onPress;
  TestContainer({this.onPress});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[600],
          ),
          child: Text(
            "Test",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

