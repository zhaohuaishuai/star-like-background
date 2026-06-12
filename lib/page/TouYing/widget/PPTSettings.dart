import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../type/touPintType.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import './block_picker.dart';
class PPTSettings extends StatefulWidget {
  int fontSize;
  StreamSink<TouYingData> sink;
  TouYingData data;
  PPTSettings({
    Key? key,
    required this.fontSize,
    required this.sink,
    required this.data,

  }) : super(key: key);
  @override
  _PPTSettingsState createState() {
    return _PPTSettingsState();
  }
}

class _PPTSettingsState extends State<PPTSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: HexColor("#F9F871"),width: 1),
            borderRadius: BorderRadius.circular(10)
          ),
          child: ListView(
            scrollDirection:Axis.horizontal,
            children: [
              RegulatorWidget(
                  label: "字号",
                  onPressed:(String type){
                    if(type == "add"){
                      widget.data.fontSize+=1;
                      widget.sink.add(widget.data);
                    }else if (type == "minimize"){
                      widget.data.fontSize-=1;
                      widget.sink.add(widget.data);
                    }
                  }
              ),
              SizedBox(width: 20,),
              RegulatorWidget(
                  label: "标题字号",
                  onPressed:(String type){
                    if(type == "add"){
                      widget.data.titleFontSize+=1;
                      widget.sink.add(widget.data);
                    }else if (type == "minimize"){
                      widget.data.titleFontSize-=1;
                      widget.sink.add(widget.data);
                    }
                  }
              ),
              SizedBox(width: 20,),
              RegulatorWidget(
                label: "行高",
                // num:widget.data.lineHeight,
                onPressed: (String type){
                  if(type == "add"){
                    widget.data.lineHeight+=1;
                    widget.sink.add(widget.data);
                  }else if (type == "minimize"){
                    widget.data.lineHeight-=1;
                    widget.sink.add(widget.data);
                  }

                },
              ),
              SizedBox(width: 20,),
              JiShuQi(
                label: "行数",
                num:widget.data.rows,
                onPressed: (String type){
                  if(type == "add"){
                    widget.data.rows+=1;
                    widget.sink.add(widget.data);
                  }else if (type == "minimize"){
                    widget.data.rows-=1;
                    widget.sink.add(widget.data);
                  }
                },
              ),
              TextAlignmentSetting(
                  textAlign: TextAlign.center,
                  sink: widget.sink,data:widget.data),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ColorSetting(
                    pickerColor: HexColor(widget.data.fontColor),
                    label: "字体颜色",
                    onColorChanged: (Color color){
                      String colorString =  ColorToHex(color).toString() ;
                      String valueString = colorString.split('(0x')[1].split(')')[0];
                      String hexString = "#${valueString.replaceAll("ff", "")}";
                      print(hexString);
                      widget.data.fontColor = hexString;
                      widget.sink.add(widget.data);
                    },
                  ),
                  ColorSetting(
                    pickerColor: HexColor(widget.data.bgColor),
                    label: "背景颜色",
                    onColorChanged: (Color color){
                      String colorString =  ColorToHex(color).toString() ;
                      String valueString = colorString.split('(0x')[1].split(')')[0];
                      String hexString = "#${valueString.replaceAll("ff", "")}";
                      widget.data.bgColor = hexString;
                      widget.sink.add(widget.data);
                    },
                  ),
                ],
              )


            ],
          )
      ),
    );
  }
}





class RegulatorWidget extends StatefulWidget {
  String label;
  void Function(String type) onPressed;
  RegulatorWidget({Key? key,required this.onPressed,required this.label}) : super(key: key);

  @override
  _RegulatorWidgetState createState() {
    return _RegulatorWidgetState();
  }
}

class _RegulatorWidgetState extends State<RegulatorWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        GestureDetector(
          child: Container(
            height: 80,width: 18,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor("#FFFFFF")
            ),
            child: Center(
              child: Container(
                height: 60,width: 16,
                child: Column(
                  children: [
                    Container(
                      width: 16,height: 10,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: HexColor("#250404"),width: 1))
                      ),
                    ),
                    Container(
                      width: 16,height: 10,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: HexColor("#250404"),width: 1))
                      ),
                    ),Container(
                      width: 16,height: 10,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: HexColor("#250404"),width: 1))
                      ),
                    ),Container(
                      width: 16,height: 10,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: HexColor("#250404"),width: 1))
                      ),
                    ),Container(
                      width: 16,height: 10,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: HexColor("#250404"),width: 1))
                      ),
                    ), Container(
                      width: 16,height: 10,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: HexColor("#250404"),width: 1))
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: HexColor("#6d6161")
                ),
              ),
            ),
          ),
          onVerticalDragUpdate: (DragUpdateDetails details) {
            print(details.delta.dy.toString());
            if(details.delta.dy<0){
              widget.onPressed("add");
            }else{
              widget.onPressed("minimize");
            }
          },
        ),
        Text(widget.label,style: TextStyle(
          color: HexColor("#FFFFFF")
        ),)
      ],
    );
  }



}



class JiShuQi extends StatelessWidget {
  int num;
  String label;
  void Function(String type) onPressed;

  JiShuQi({
    Key? key,
    required this.num,
    required this.onPressed,
    required this.label
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: new EdgeInsets.only(left: 3,right: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          InkWell(
            onTap: (){onPressed("add");},
            child: Icon(Icons.add,color: Colors.white)
          ),
          SizedBox(height: 10,),
          Text(this.num.toString(),style: TextStyle(color: Colors.white),),
          InkWell(
            onTap: (){onPressed("minimize");},
            child: Icon(Icons.minimize_sharp,color: Colors.white),
          ),
          SizedBox(height: 5,),
          Text("$label",style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}


class TextAlignmentSetting extends StatelessWidget {
  TextAlign textAlign;

  StreamSink<TouYingData> sink;
  TouYingData data;
  TextAlignmentSetting(
      {
        Key? key,
        required this.textAlign,
        required this.data,
        required this.sink
      }
      ) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 120,
      height:100,
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white,fontSize: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(child: Text("左对齐",style: textColor('left')),onTap: (){
              data.textAlign = "left";
              sink.add(data);
            },),
            InkWell(child: Text("居中对齐",style: textColor('center')),onTap: (){
              data.textAlign = "center";
              sink.add(data);
            },),
            InkWell(child: Text("右对齐",style: textColor('right'),),onTap: (){
              data.textAlign = "right";
              sink.add(data);
            },),
          ],
        ),
      ),
    );
  }

  TextStyle textColor(String textAlign){
    return TextStyle(color: data.textAlign == textAlign?HexColor("#F9F871"):Colors.white);
  }

}


class ColorSetting extends StatelessWidget {
  Color pickerColor;
  String label;
  void Function(Color color) onColorChanged;
  ColorSetting({
    Key? key,
    required this.label,
    required this.pickerColor,
    required this.onColorChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(0),
              content: SingleChildScrollView(
                child: MaterialPicker(
                  pickerColor: pickerColor,
                  onColorChanged: onColorChanged,
                  enableLabel: false,
                  portraitOnly: false,
                ),
              ),
            );
          },
        );
      },
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color:Colors.white),
          ),
          SizedBox(width: 10,),
          Container(
            width: 26,height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: pickerColor,
            ),
          )
        ],
      ),

    );
  }
}
