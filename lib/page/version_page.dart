import 'package:Shine_like_a_star/config/color.dart';
import 'package:Shine_like_a_star/container/sgbContainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import '../type/sgbType.dart';
import 'package:badges/badges.dart' as badges;
class VersionPage extends StatefulWidget {
  VersionPage({Key? key}) : super(key: key);
  @override
  _VersionPageState createState() {
    return _VersionPageState();
  }
}

class _VersionPageState extends State<VersionPage> {
  final ScrollController scrollController = ScrollController();
  SgbContainer sgbContainer = Get.find<SgbContainer>();
  int page = 1;
  int limit = 30;
  int count = 10;
  List<Version> list = [];
  bool loading = false;
  String loadingText = '加载中...';
  @override
  void initState() {
    super.initState();
    getList().then((_){
      if(count == list.length){
        setState(() {
          loadingText = '没有更多了';
        });
      }
    });
    scrollController.addListener(() {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
        next();
      }
    });
  }

  next(){
    if(count == list.length){
      setState(() {
        loadingText = '没有更多了';
      });
      return;
    };
    setState(() {
      page++;
      getList();
    });
  }
  getList () async{
    setState(() {
      loading = true;
      loadingText = '加载中...';
    });
    try{
      var res =  await sgbContainer.api.getVersions(page, limit);

      if(res.body == null){
        Get.snackbar('错误提示', '网络出现问题',
            duration:Duration(milliseconds: 700),
            backgroundColor:Colors.white,
            icon:Icon(Icons.sms_failed,color: Colors.yellow));
            print("version is err -->");

      }else {
        if(res.body['code'] == 200){
          setState(() {
            count = res.body['total'];
            list.addAll(
                res.body['rows'].map((item){
                  return Version.fromJson(item);
                }).toList().cast<Version>().toList()
            );

          });
        }else {
          Get.snackbar('错误提示', '网络出现问题',duration:Duration(milliseconds: 700),
              backgroundColor:Colors.white,
              icon:Icon(Icons.sms_failed,color: Colors.yellow));
          setState((){
            loadingText = '网络出现问题';
          });
        }
      }
    }catch(err){
      print("version is err -->$err");
      Get.snackbar('错误提示', '网络出现问题',
          duration:Duration(milliseconds: 700),
          backgroundColor:Colors.white,
          icon:Icon(Icons.sms_failed,color: Colors.yellow));
      setState((){
        loadingText = '网络出现问题';
      });

    }finally{
      setState(() {
        loading = false;
      });
    }

  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body:Container(
        decoration: BoxDecoration(
            gradient: AppColor.appBackgroundGradient
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  BackButton(color: Colors.white,onPressed: (){Get.back();},)
                ],
              ),
              SizedBox(height: 20,),
              Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [

                      ...List.generate(list.length, (index) {
                        var item = list[index];
                        return badges.Badge(
                          position: badges.BadgePosition(end: 6,top: 1),
                          badgeColor: Colors.blue,
                          showBadge: sgbContainer.versionShowDialog.value && index == 0,
                          badgeContent:Text("未读",style: TextStyle(fontSize: 15,color: Colors.white),),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white70,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 8.0,
                                  offset: Offset(6,6),
                                )
                              ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "版本号：${item.version.toString()}"
                                  ),
                                  Html(data:item.context.toString()),
                                  Text("更新日期：${DateTime.parse(item.createdAt.toString()).year}-${DateTime.parse(item.createdAt.toString()).month}-${DateTime.parse(item.createdAt.toString()).day} ${DateTime.parse(item.createdAt.toString()).hour}:${DateTime.parse(item.createdAt.toString()).minute}:${DateTime.parse(item.createdAt.toString()).second}"
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                          ),
                      Text(
                        loadingText,style: TextStyle(color: Colors.white,fontSize: 16,),textAlign: TextAlign.center,)
                    ],
                  ),
                ),
              SizedBox(height: 10,)
            ],
          )
        ),
      )
    );
  }
}