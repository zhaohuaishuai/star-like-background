import 'package:flutter/material.dart';

class AppColor {
  static get primary {
    return Color(0xFF6A76AB);
  }


  static final appBackgroundColor = Colors.grey[300];
  static final titleFontColor = Color.fromARGB(255, 57, 77, 120);
  static final xuhaoFontColor = Color.fromARGB(255, 116, 133, 168);
  static final appBackgroundGradient = LinearGradient(
  colors: [Color.fromARGB(255, 27, 49, 139),Color.fromARGB(89, 88, 116, 220)],
  stops: [0.3,1]
  );
  static final appListBackgroundGradient =  LinearGradient(
  begin: Alignment.bottomCenter,
  end:Alignment.topCenter,
  colors: [
      Colors.white.withOpacity(.5),
      Colors.white.withOpacity(1)
  ]
  );
  static final appPlayerBackgroundGradient = LinearGradient(
    // rgba(41, 41, 51, 1)
    // rgba(25, 50, 148, 1)
      colors: [Color.fromARGB(255,25, 50, 148),Color.fromARGB(255,41, 41, 51)],
      begin: Alignment.topCenter,
      end:Alignment.bottomCenter
  );
  static final defaultImag = "https://www.top237.top/lsky/2023/01/06/63b7bf356d8e4.jpg";
}
