import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../type/touPintType.dart';
import '../../../widget/SgbSelect.dart';
import 'package:get/get.dart';
class QuickOptionsWidget extends StatelessWidget {
  Stream<TouYingData> stream;
  StreamSink<TouYingData> sink;
  TouYingData touYingData ;
  GlobalKey<SgbSelectState> sgbGlobalKey;
  ScrollController _controller = new ScrollController();
  QuickOptionsWidget(
      {
        Key? key,
        required this.stream,
        required this.touYingData,
        required this.sink,
        required this.sgbGlobalKey
      }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        height: 130,
        padding: EdgeInsets.symmetric(vertical: 6,horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HexColor("#F9F871"),width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(onPressed: (){
              bool cqu = touYingData.quickOptions.any((element) => element.title == touYingData.title);
              if(cqu){
                Get.snackbar('当前数据已经有了', "提示",
                    duration:
                    Duration(milliseconds: 700),
                    backgroundColor: Colors.white,
                    icon: Icon(Icons.star,
                        color: Colors.yellow));
                return;
              }

              QuickOptions qu = QuickOptions(
                sId: "1",
                xuhao: "1",
                selected: false,
                lyric: touYingData.lyric,
                title: touYingData.title,
              );
              touYingData.quickOptions.add(qu);
              sink.add(touYingData);
              Get.snackbar('添加成功',touYingData.title,
                  duration:
                  Duration(milliseconds: 700),
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.star,
                      color: Colors.yellow));
              _controller.animateTo(10000000000, duration: Duration(milliseconds: 500), curve: Curves.bounceOut);
            }, icon: Icon(Icons.add,color: Colors.white,)),
            Container(
              height: 60,
              child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: touYingData.quickOptions.length ,
                  itemBuilder: (_,int index){
                    // index = 0;
                    QuickOptions quickOptions = touYingData.quickOptions[index];
                    return
                      Row(
                        children: [
                          InkWell(
                            onTap: (){
                              touYingData.title = quickOptions.title;
                              touYingData.lyric = quickOptions.lyric;
                              touYingData.quickOptions = touYingData.quickOptions.map((QuickOptions qu){
                                if(qu.title == quickOptions.title){
                                  qu.selected = true;
                                }else {
                                  qu.selected = false;
                                }
                                return qu;
                              }).toList();
                              sgbGlobalKey.currentState!.setText("${quickOptions.title}");
                              touYingData.pageIndex = 1;
                              sink.add(touYingData);
                            },
                            child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(vertical: 6,horizontal: 10),
                                // margin: EdgeInsets.symmetric(vertical: 2,horizontal: 3),
                                decoration: BoxDecoration(
                                  color:quickOptions.selected?HexColor("#008F7A"): HexColor("#0089BA"),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),bottomLeft: Radius.circular(15)),
                                ),
                                child: Center(child: Text(quickOptions.title,style: TextStyle(color: HexColor("#FFFFFF")),))),),
                          InkWell(
                            onTap: (){
                              touYingData.quickOptions.removeAt(index);
                              sink.add(touYingData);
                            },
                            child: Container(
                              height: 30,
                              width: 50,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color:quickOptions.selected?HexColor("#008F7A"): HexColor("#0089BA"),
                                borderRadius: BorderRadius.only(topRight: Radius.circular(15),bottomRight: Radius.circular(15)),
                              ),
                              child: Icon(Icons.close,color: Colors.white,),
                            ),
                          )
                        ],);
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}
