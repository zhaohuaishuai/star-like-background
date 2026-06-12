import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';

import 'package:m/features/pages/home/index.dart';
import 'package:m/features/pages/my/index.dart';
import 'package:m/features/pages/sgb/index.dart';

import 'package:m/shared/widgets/first_guide_widget/index.dart';
import 'package:m/shared/widgets/mini_player.dart';

GetStorage box = GetStorage();

// ignore: must_be_immutable
class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IndexPage createState() => _IndexPage();
}

class _IndexPage extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: box.readBool(GetStorage.notFirstStart),
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          if (snapshot.data == true) {
            return const HomeWidget();
          }

          debugPrint('snapshot.data:${snapshot.data}');

          return FirstGuideWidget(
            onFinished: () async {
              if (!kIsWeb) {
                await Utils.firstStartServices();
              }
              await box.writeBool(GetStorage.notFirstStart, true);
              setState(() {});
            },
          );
        });
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _currentPage = 0;
  late PageController _pageController;

  late final List<Widget> _pages = [
    HomePage(
      onTabChange: (index) {
        _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
      },
    ),
    const SgbPage(),
    const SizedBox(),
    const SizedBox(),
    MyPage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavIems = [
    BottomNavigationBarItem(
        icon: const Icon(
          Icons.star_border,
          weight: 100,
        ),
        activeIcon: const Icon(
          Icons.star,
        ),
        label: '首页'.tr),
    BottomNavigationBarItem(
        icon: const Icon(
          Icons.bookmark_border_outlined,
          weight: 100,
        ),
        activeIcon: const Icon(
          Icons.bookmark,
        ),
        label: '诗歌本'.tr),
    BottomNavigationBarItem(
        icon: const Icon(
          weight: 100,
          Icons.book_outlined,
        ),
        activeIcon: const Icon(weight: 100, Icons.book),
        label: '经文'.tr),
    BottomNavigationBarItem(
        icon: const Icon(
          weight: 100,
          Icons.screen_share,
        ),
        activeIcon: const Icon(weight: 100, Icons.screen_share),
        label: '投屏'.tr),
    BottomNavigationBarItem(
        icon: const Icon(
          weight: 100,
          Icons.person_outline_outlined,
        ),
        activeIcon: const Icon(weight: 100, Icons.person),
        label: '我的'.tr),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _pageController.addListener(() {
      setState(() {
        int index = _pageController.page!.toInt();
        _currentPage = index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: PageView(
            controller: _pageController,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: _bottomNavIems,
            currentIndex: _currentPage,
            onTap: (value) =>
                onCurrentIndexChange(value: value, isUserInteraction: true),
          ),
        ),
        // MiniPlayer 播放器

        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          bottom: _currentPage == 3
              ? -StarThemeData.bottomPadding
              : StarThemeData.bottomPadding,
          left: 0,
          width: MediaQuery.of(context).size.width,
          height: StarThemeData.miniPlayerHeight,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _currentPage == 3 ? 0 : 1,
            child: MiniPlayer(),
          ),
        ),

        // Positioned(
        //   top: MediaQuery.of(Get.context!).padding.top,
        //   left: 0,
        //   child: TextButton(
        //     child: Text('生成报错'),
        //     onPressed: () async {

        //     throw FlutterError("测试报错");
        //     },
        //   ),
        // )
      ],
    );
  }

  bool onCurrentIndexChange({required int value, bool? isUserInteraction}) {
    if (value == 3) {
      Get.toNamed(AppRoutes.screenCating);
      return false;
    }
    if (value == 2) {
      Get.toNamed(AppRoutes.jingwengres);
      return false;
    }
    if (isUserInteraction ?? false) {
      _pageController.animateToPage(
        value,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
    return true;
    // _pageController.animateToPage(
    //   value,
    //   duration: const Duration(milliseconds: 100),
    //   curve: Curves.easeInOut,
    // );
  }
}
