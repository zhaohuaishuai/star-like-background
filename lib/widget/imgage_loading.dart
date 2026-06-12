import 'package:flutter/material.dart';

class ImageLoading extends StatelessWidget {
  final String imagePath;
  ImageLoading({Key?key,required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Image.network(imagePath
      ,loadingBuilder: (_,w,e){
        if(e == null)return w;
        return CircularProgressIndicator();
      },
    );
  }
}
