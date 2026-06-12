import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/color.dart';
class BackBtn extends StatelessWidget {
  BackBtn({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Get.back();
        });
  }
}

class StarScaffold extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  StarScaffold({
    Key? key,
    required this.child,
    this.actions,
    this.leading,
    this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            title: title,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: leading == null ? BackBtn() : leading,
            actions: actions ?? [],
        ),
        body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.only(top: mediaQuery.padding.top),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColor.primary
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                              "https://oss.top237.top/img/star_web_bg_1080.jpg"
                          ),
                        fit: BoxFit.cover,
                      ),
                    )
                  ),
                  Container(

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:Alignment.bottomCenter,
                        colors: [AppColor.primary, Colors.transparent],
                      ),
                    ),
                  ),

                  child

                ],
              )),
        ));
  }
}
