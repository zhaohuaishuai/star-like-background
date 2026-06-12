import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.white,),
            SizedBox(height: 20,),
            Text("加载中...",style: TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
