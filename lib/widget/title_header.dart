import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final onPressed;
  final bool? lookMore;
  final Widget? rightBtn;
  TitleHeader({Key? key, required this.title, required this.icon,this.onPressed,this.lookMore,this.rightBtn})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.cyan,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 20))
                ],
              ),
            ],
          ),
          (onPressed != null)?
          Row(
            children: [
               Text("查看更多",style:TextStyle(color:Colors.white)),
               IconButton(onPressed: (){
                  if(onPressed!=null){
                    onPressed();
                  }
                }, icon: Icon(Icons.arrow_circle_right_rounded),color: Colors.white,)
            ],
          ):Container(child: rightBtn,),
        ],
      ),
    );
  }
}
