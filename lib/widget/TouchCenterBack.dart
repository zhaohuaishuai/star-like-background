import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TouchCenterBack extends StatelessWidget {
  const TouchCenterBack({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.touch_app_outlined,color: Colors.yellow,size: 18,),
        Text('点击屏幕任意区域退出',style:TextStyle(
            fontFamily: "WenQuanDengKuanWeiMiHei",
            fontWeight: FontWeight.w100,
            fontSize: 13, height: 2,decoration:TextDecoration.none,color: Colors.white))
      ],
    );
  }
}