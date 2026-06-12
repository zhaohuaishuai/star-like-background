import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:Shine_like_a_star/config/color.dart';
import 'package:Shine_like_a_star/page/TouYing/widget/PPTSettings.dart';
import 'package:Shine_like_a_star/page/TouYing/widget/QuickOptionsWidget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_3/flutter_swiper_3.dart';
import 'package:get_storage/get_storage.dart';
import '../../type/touPintType.dart';
import "package:flutter/material.dart";
import '../../widget/SgbSelect.dart';
import '../../type/sgbType.dart';
import '../../type/touPintType.dart';
import '../../utils/mqtt/mqtt_client.dart'
if (dart.library.html) '../../utils/mqtt/mqtt_browser.dart';
import '../../utils/mqtt/mqtt.dart';
import 'package:hexcolor/hexcolor.dart';
import './widget/PPTSlidersSwiper.dart';
import '../../container/sgbContainer.dart';
import 'package:get/get.dart';
class TPController extends StatefulWidget {
  TPController({Key? key}) : super(key: key);
  @override
  _TPControllerState createState() {
    return _TPControllerState();
  }
}

class _TPControllerState extends State<TPController> {
  SgbContainer sgbContainer = Get.find<SgbContainer>();
  late CustomMqtt _customMqtt;
  StreamController<TouYingData> _streamController = new StreamController<TouYingData>.broadcast();
  late Stream<TouYingData> _stream;
  late StreamSink<TouYingData> _streamSink;
  late TouYingData touYingData;
  late TabController tabController;
  bool firstMessage = true;
  GlobalKey<SgbSelectState> sgbGlobalKey = new GlobalKey();
  String smallPageLyric = "";
  String smallPageFontColor = "";
  String smallPagebgColor = "";
  int smallPageRows = 0;
  int smallPageIndexPage = 0;

  @override
  void initState()  {
    init();
  }
  void init() async {
    print("初始化成功");
    _stream = _streamController.stream;
    _streamSink = _streamController.sink;
    touYingData = await Mqtt.loadDefaultTmp();
    _streamSink.add(touYingData);
    _customMqtt = CustomMqtt(
      code: this.code,
      onConnected: (){
        print("连接成功");
        _stream.listen(onStreamListen);
      },
      onMessage: onMessage
    );
    _customMqtt.connect();

  }

  @override
  void dispose() {
    _customMqtt.disconnect();
    _streamSink.close();
    _streamController.close();
    super.dispose();
  }
  // 重新选择
  onSelect(SgbData value){
    print("选择框");
    touYingData.lyric = value.dmturl.lyric;
    touYingData.title = value.full_title;
    touYingData.pageIndex = 0;
    _streamSink.add(touYingData);
  }
  // 翻页
  onIndexChanged(int index){
    touYingData.pageIndex = index;
    publishMessage(touYingData);
    // _streamSink.add(touYingData);
  }
  // 监听流的变化并且发消息
  onStreamListen(TouYingData event){
      setState(() {
        smallPageLyric = event.lyric;
        smallPagebgColor = event.bgColor;
        smallPageFontColor = event.fontColor;
        smallPageRows = event.rows;
        smallPageIndexPage = event.pageIndex;
      });
     publishMessage(event);
  }
  // 发送消息
  publishMessage(TouYingData touYingData){
    _customMqtt.publishMessage(jsonEncode(touYingData.toJson()));
  }
  onMessage(TouYingData touYingData){
    if(firstMessage) {
      print("收到的第一条回显信息-->${touYingData.pageIndex}");
      this.sgbGlobalKey.currentState!.setText(touYingData.title);
      this.touYingData = touYingData;
      _streamSink.add(touYingData);
      firstMessage = false;
    }
  }

  get code => sgbContainer.sgbStorage.touPingCode;
  resetCode(int code){
    print(code);
    sgbContainer.sgbStorage.touPingCode = code;
    firstMessage = true;
    _customMqtt.setCode(code);
    Get.back();
  }


  Color bgColor = HexColor("#400C95");

  String showPage = "smallPage";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: bgColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex:1,
                    child: SgbSelect(
                      key: sgbGlobalKey,
                      onTap: (value)=>onSelect(value),
                    ),
                  ),
                ],
              ),
              floating: false,
              pinned: true,
              snap: false,
              actions: [
                IconButton(onPressed: (){}, icon: Icon(Icons.more_vert)),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 230,
                child: StreamBuilder<TouYingData>(
                    stream:_streamController.stream,
                    builder: (_,AsyncSnapshot snapshot){
                      if(snapshot.connectionState == ConnectionState.active){
                        print("重新渲染");
                        TouYingData data = snapshot.data as TouYingData;
                        return PPTSlidersSwiper(
                          lyric: data.lyric,
                          row: data.rows,
                          pageIndex:data.pageIndex,
                          bgColor:data.bgColor,
                          fontSize:data.fontSize,
                          onIndexChanged:onIndexChanged,
                          fontColor: data.fontColor,
                          titleFontSize: data.titleFontSize,
                          title: data.title,
                          lineHeight: data.lineHeight,
                          textAlign: data.textAlign,
                        );
                      }
                      return Container(
                        height: 230,
                        child: Center(child: Text("请选择赞美")),);
                    }),
              ),
            ),
            // 连接设置
            SliverToBoxAdapter(
              child: ConnectSetting(onSubmit: resetCode, code: this.code,),
            ),
            // 设置
            SliverToBoxAdapter(
              child: Container(
                child: StreamBuilder<TouYingData>(
                  stream: _stream,
                  builder: (_,AsyncSnapshot snapshot){
                    if(snapshot.connectionState == ConnectionState.active){
                      TouYingData data = snapshot.data as TouYingData;
                      return PPTSettings(
                        fontSize: data.fontSize,
                        sink: _streamSink,
                        data: data,
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
            // 快捷选项
            SliverToBoxAdapter(
              child: Container(
                child: StreamBuilder<TouYingData>(
                    stream:_streamController.stream,
                    builder: (_,AsyncSnapshot snapshot){
                      if(snapshot.connectionState == ConnectionState.active){
                        TouYingData data = snapshot.data as TouYingData;
                        return QuickOptionsWidget(
                          stream: _stream,
                          touYingData: touYingData,
                          sink: _streamSink,
                          sgbGlobalKey: sgbGlobalKey,
                        );
                      }
                      return Container();
                    }),
              ),
            ),

            // 缩略图
            StreamBuilder<TouYingData>(
              stream: _stream,
              builder: (_,AsyncSnapshot snapshot){
                if(snapshot.connectionState == ConnectionState.active){
                  TouYingData data = snapshot.data as TouYingData;
                  return SmallPages(
                    sink: _streamSink,
                    data: data,
                  );
                }
                return SliverToBoxAdapter();
              },
            ),

          ],
        )
      )
    );
  }
}



class SmallPages extends StatelessWidget {
  StreamSink<TouYingData> sink;
  TouYingData data;
  SmallPages({
    Key? key,
    required this.sink,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<String> tmplist = data.lyric.split("\n");
    List<List<String>> list = splitArray(tmplist,data.rows);
    list.insert(0, [data.title]);
    list.insert(0, []);
    TextAlign _textAlign = TextAlign.center;

    switch(data.textAlign){
      case "left":
        _textAlign = TextAlign.left;
        break;
      case "right":
        _textAlign = TextAlign.right;
        break;
    }

    return SliverPadding(
        padding: EdgeInsets.all(8),
        sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, index) {
              return InkWell(
                onTap: (){
                  data.pageIndex = index;
                  sink.add(data);
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color:  HexColor(data.bgColor),
                      border: data.pageIndex == index? Border.all(color: HexColor("#F9F871"),width: 3):null
                    ),
                    child: Center(
                      child:
                          Text(list[index].join("\n"),
                          textAlign: _textAlign,
                          style: TextStyle(
                            color: HexColor(data.fontColor),
                            fontSize: 10,
                          ))),

                ),
              );
            },
            childCount: list.length
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing:5,
                crossAxisSpacing: 5,
                childAspectRatio:3/2
            ),

        ),
    );
  }

  List<List<T>> splitArray<T>(List<T> arr, int size) {
    List<List<T>> result = [];
    for (int i = 0; i < arr.length; i += size) {
      List<T> chunk = arr.sublist(i, i + size > arr.length ? arr.length : i + size);
      result.add(chunk);
    }
    return result;
  }
}


class ConnectSetting extends StatefulWidget {
  int code ;
  void Function(int code) onSubmit;
  ConnectSetting({Key? key,required this.onSubmit,required this.code}) : super(key: key);

  @override
  _ConnectSettingState createState() {
    return _ConnectSettingState();
  }
}

class _ConnectSettingState extends State<ConnectSetting> {

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.code.toString();
  }
  @override
  void dispose() {
    super.dispose();
  }
  TextEditingController textEditingController = new TextEditingController();


  Widget SetintCodeDia(){
    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Container(
        // height: 60,
        padding: const EdgeInsets.all(8.0),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(.5),
          // border: Border.all(color: HexColor("#F9F871"),width: 1)
        ),
        child: TextField(
          controller: textEditingController,
          onEditingComplete: (){
            if(textEditingController.value.text == ""){return;}
            if(textEditingController.value.text.length != 4){return;}
            widget.onSubmit(int.parse(textEditingController.value.text));
          },
          style: TextStyle(
            // color: Colors.white,
            fontSize: 16,

          ),
          maxLength: 4,
          decoration: InputDecoration(
            labelText: "请输入连接码",
            // labelStyle: TextStyle(color: Colors.white),
            suffixIcon: InkWell(onTap: (){
              if(textEditingController.value.text == ""){return;}
              if(textEditingController.value.text.length != 4){return;}
              widget.onSubmit(int.parse(textEditingController.value.text));
            },child: Text("确认",style: TextStyle(color: Colors.blueAccent,height: 0),)),
            border: UnderlineInputBorder(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(6),
              contentPadding: const EdgeInsets.all(0),
              // title: Text("设置连接码",style: TextStyle(fontSize: 16),),
              content: SetintCodeDia(),
            );
          },
        );
      },
      child: Text("设置连接码",style: TextStyle(color: Colors.white),),
    );
  }
}