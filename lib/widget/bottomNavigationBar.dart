import 'package:Shine_like_a_star/page/player_page.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../widget/RotationWidget.dart';
import 'package:get/get.dart';
import '../container/sgbContainer.dart';

class CusBottomNavigationBar extends StatefulWidget {
  final onChange;
  final int currentIndex;
  CusBottomNavigationBar({Key? key, this.onChange,required this.currentIndex}) : super(key: key);
  @override
  _CusBottomNavigationBarState createState() {
    return _CusBottomNavigationBarState();
  }
}

class _CusBottomNavigationBarState extends State<CusBottomNavigationBar> with TickerProviderStateMixin{

  final double iconsize = 26;
   var _currentIndex = 0;
   AudioPlayer player = Get.find<SgbContainer>().player.value;
  // homeIcon
  homeIcon(){

    switch(widget.currentIndex) {
      case 0:
      //返回聊天页面
        return Image.asset("assets/images/home_nav_bar_icon_active.png",width: iconsize,height: iconsize,);
      case 1:
      //返回好友页面
        return Image.asset("assets/images/home_nav_bar_icon.png",width: iconsize,height: iconsize);
    }
  }
  meIcon(){
    switch(widget.currentIndex) {
      case 0:
      //返回聊天页面
        return Image.asset("assets/images/me_nav_bar_icon.png",width: iconsize,height: iconsize,);
      case 1:
      //返回好友页面
        return Image.asset("assets/images/me_nav_bar_icon_active.png",width: iconsize,height: iconsize);
    }
  }

  late AnimationController  animController ;
  @override
  void initState() {

    animController = AnimationController(vsync: this,duration: Duration(seconds: 10));
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        print("status is completed");
        //重置起点
        animController.reset();
        //开启
        animController.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        print("status is dismissed");
      } else if (status == AnimationStatus.forward) {
        print("status is forward");
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
        print("status is reverse");
      }
    });
    setState(() {
      // _currentIndex = this.currentIndex;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          clipBehavior: Clip.none,
          fit:StackFit.loose,
          alignment:Alignment.topCenter,
          children: [
            Positioned(
                bottom: 0,
                child: Image.asset("assets/images/bottomNavBar.png",
                  width: MediaQuery.of(context).size.width,
                  height: 90,
                  fit:BoxFit.fill,)
            ),
            Positioned(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60,vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      setState(() {
                         widget.onChange(0);
                      });
                    },
                    child: Column(
                      children: [
                        homeIcon(),
                        Text("首页",style:TextStyle(color: _currentIndex == 0?Colors.white:Colors.grey,fontSize: 11),)
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        widget.onChange(1);
                      });
                    },
                    child: Column(
                      children: [
                        meIcon(),
                        Text("我的 ",style:TextStyle(color: _currentIndex ==1?Colors.white:Colors.grey,fontSize: 11),)
                      ],
                    ),
                  )
                ],
              ),
            )),
            Positioned(
                bottom: 14,
                child: Container(
                  width: 60,height: 60,
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          colors: [
                            Color.fromARGB(255, 85, 76, 210),
                            Color.fromARGB(205, 85, 76, 210),
                          ]

                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2),offset: Offset(5,5),blurRadius: 10)
                      ],
                      color: Colors.white,borderRadius: BorderRadius.circular(30)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(3),
                          child: ClipRRect(
                              borderRadius:BorderRadius.circular(60),
                              child:  RotationWidget(
                                onTap: (){
                                  Get.toNamed("/playerPage");
                                },
                                child: Image.asset("assets/images/border_logo.png",alignment: Alignment.center,fit:BoxFit.fill,),
                              )
                          )
                      ),
                      SizedBox(
                        width:25,height:25,
                        child: InkWell(
                            onTap: (){
                              Get.toNamed("/playerPage");
                            },
                            child: Image.asset("assets/images/logo.png")),
                      )

                    ],
                  )
                ))

          ],
        )
    );
  }
}


