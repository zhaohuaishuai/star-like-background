// import 'dart:html';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_html/shims/dart_ui.dart';
// class WebImg extends StatelessWidget {
//   final String src;
//   final int? width;
//   final int? height;
//   WebImg({Key? key,required this.src, this.width,  this.height}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     String _divId = "img" + DateTime.now().toIso8601String();
//     ImageElement img = ImageElement(src:src,width: width,height: height);
//     platformViewRegistry.registerViewFactory(_divId, (viewId) => img);
//     img.style.zIndex = "100";
//     return HtmlElementView(viewType: _divId);
//   }
// }