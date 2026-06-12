import 'package:flutter/material.dart';
import '../widget/new_box.dart';
class ListBtn extends StatelessWidget {
  final bool show ;
  final onTab;
  ListBtn({Key? key,required this.show,this.onTab}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onTab == null ? '':onTab();
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: show ? NewBox(child: Icon(Icons.close)):NewBox(child: Icon(Icons.menu)),
      ),
    );
  }
}
