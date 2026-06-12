import "package:flutter/material.dart";
import 'package:get/get.dart';
import '../container/sgbContainer.dart';
import 'package:just_audio/just_audio.dart';
import './home.dart';
import './me.dart';
import '../config/color.dart';
import '../widget/bottomNavigationBar.dart';
import './index.dart';
import '../widget/PubScaffold.dart';
class NewIndexPage extends StatefulWidget {
  const NewIndexPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewIndexPage();
  }
}

class _NewIndexPage extends State<NewIndexPage>  with SingleTickerProviderStateMixin{

  final AudioPlayer player = Get.find<SgbContainer>().player.value;
  final sgbContainer = Get.find<SgbContainer>();
  late TabController tabController;
  //当前选中页面索引
  var _currentIndex = 0;
  //聊天页面
  IndexPage newIndexPage = IndexPage();
  //好友页面
  Me songPage = Me();
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2,vsync: this);
    tabController.addListener(() {
      print(tabController.index);
      setState(() {
        _currentIndex = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) => _insertOverlay(context));
    return Scaffold(
        bottomNavigationBar: CusBottomNavigationBar(
          currentIndex:_currentIndex,
          onChange: (index) {
            tabController.animateTo(index);
          },
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
          child: TabBarView(
            controller: tabController,
            children: [
              newIndexPage,
              songPage,
            ],
          ),
        ));
  }
}
