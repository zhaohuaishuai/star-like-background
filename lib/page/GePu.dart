import 'package:Shine_like_a_star/config/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/utils.dart';
import '../widget/TouchCenterBack.dart';
import 'package:Shine_like_a_star/utils/downUtils.dart'
    if (dart.library.html) 'package:Shine_like_a_star/utils/downHtmlUtils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
Future<String> getImgUrl({required String url,required String fileName}) async {
  String savePath;
  savePath = await downPer.getSavePath(url, 'star/gepu/$fileName');
  bool isGranted = await downPer.isGranted();
  bool isExist = await downPer.testFile(savePath);

  if(isGranted && isExist){
    return savePath;
  }else{
    Dio dio = Dio();
    await dio.download(url, savePath);
    return savePath;
  }
}

String loadingGif = "assets/images/dengta.gif";

class GePu extends StatelessWidget {
  GePu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)  {
    var url = Get.parameters['url'] as String;
    var title = Get.parameters['title'] ?? DateTime.now().toString();

    Jutils.setWebTitle("歌谱-$title");

    MatomoTracker.instance.trackEvent(eventCategory: 'look', action: '歌谱', eventName: title);
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Container(
        decoration:
            BoxDecoration(gradient: AppColor.appPlayerBackgroundGradient),
        child: SafeArea(
            child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        "双击或着手指拖拽放大图片",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (PlatformUtils.isWeb) {
                            await downFile.down('${title}.jpeg', "${url}");
                            return;
                          }
                          await downFile.savePhont('${title}.jpeg', "${url}");
                        },
                        child: Row(
                          children: [
                            Text(
                              "下载歌谱",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.download,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<String>(
                  future: getImgUrl(url: url, fileName: title),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot){

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Image.asset(loadingGif); // loading状态下显示一个转圈
                    } else {
                      if (snapshot.hasError)
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('没有找到这首歌谱',style:TextStyle(fontSize: 20,decoration: TextDecoration.none,color: Colors.grey.shade400))]);
                      else
                        return PhotoView(
                            imageProvider: FileImage(File(snapshot.data as String)),
                            loadingBuilder: (BuildContext _, event) {
                              return Image.asset(loadingGif);
                            },
                            errorBuilder: (_, o, t) {
                              return Center(
                                child: Text(
                                  '没有找到这首歌谱!',
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            });// 数据获取成功，显示获取到的数据
                    }
                  },
                ),
              ),
              TouchCenterBack(),
            ],
          ),
        )),
      ),
    );
  }
}
