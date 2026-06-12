 

import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/user.dart';

/// 首次启动引导页
class FirstGuideWidget extends StatefulWidget {
  final VoidCallback? onFinished;
  const FirstGuideWidget({super.key, this.onFinished});

  @override
  State<FirstGuideWidget> createState() => _FirstGuideWidgetState();
}

class _FirstGuideWidgetState extends State<FirstGuideWidget> {
  GetStorage box = GetStorage();
  UserProvider api = Get.put<UserProvider>(UserProvider());
  @override
  void initState() {
    super.initState();
   
  }

  @override
  void dispose() {
    super.dispose();
  }

  final String _imgUrl = 'assets/img/app_index_start.jpg';

  void onPressed () async {
    debugPrint('首次启动引导页');
    if (kIsWeb) {
      widget.onFinished?.call();
      return;
    } 
    if(Platform.isAndroid){
      widget.onFinished?.call();
      return;
    }
    Toast.showToast('加载中...');
    Utils.testNetWork()
        .then((respose) {
      debugPrint('首次启动引导页${respose.data}');
      widget.onFinished?.call();
    }).catchError((e) {
      Get.defaultDialog(
          title: '网络错误',
          content: const Text(
              '网络错误，首次启动可能是网络授权问题!，请尝试杀掉应用进程，重新启动应用，并授权应用网络权限'),
          textCancel: '我授权了，强行进入',
          onCancel: () {
            widget.onFinished?.call();
          });
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            height:double.infinity,
            fit: BoxFit.fitHeight,
            alignment: Alignment.center,
            _imgUrl),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container( 
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.shade200.withOpacity(0.2)), 
              ),
            ),
          ),
          
          LayoutBuilder(
            builder: (context,constraints) {
              double width = constraints.maxWidth * 0.8;
              double height = width * (16 / 9);
              return ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  width:width,
                  height:height,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                  _imgUrl),
              );
            }
          ), 
          Positioned(
            bottom: 30,left: 20,right: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: StarThemeData.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              onPressed: onPressed,
              child:const Text('进入应用',style: TextStyle(color: Colors.white,fontSize: 14),),
                        ),
            )) 
        ],
      
      ),
    );
  }
}
