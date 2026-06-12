import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/data/services/sgb.dart';
import 'package:m/features/pages/home/controller.dart';
import 'package:m/shared/widgets/song_list_tile.dart';

// SgbService.to.shijiTypeList.map((e) => e.name).toList(),
class SgbPage extends GetWidget<HomeController> {
  const SgbPage({super.key});

  PopupMenuButton<int> sgbDetailBtnRender() {
    return PopupMenuButton(
      icon: const Icon(Icons.menu),
      itemBuilder: (context) {
        return SgbService.to.shijiTypeList
            .map((e) => PopupMenuItem(
                  value: e.id,
                  child: Text(e.name),
                ))
            .toList();
      },
      onSelected: (value) {
        controller.currentIndex.value = SgbService.to.shijiTypeList
            .indexWhere((element) => element.id == value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;

    return DefaultTabController(
      length: SgbService.to.shijiTypeList.length,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(StarThemeData.coverUrl),
                  ),
                ),
                child: Text(
                  '诗歌本目录'.tr,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              const ShijiTypeDirWidget(),
            ],
          ),
        ),
        appBar: AppBar(
          actions: [
            Obx(() {
              return IconButton(
                icon: Row(
                  children: [
                    Text(controller.isDesc.value ? '降序'.tr : '升序'.tr),
                    RotatedBox(
                      quarterTurns: controller.isDesc.value ? 0 : 2,
                      child: const Icon(Icons.sort),
                    ),
                  ],
                ),
                onPressed: () {
                  controller.onSort();
                },
              );
            }),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: controller.toSearch,
            ),
          ],
          title: Text('诗歌本'.tr),
          bottom: TabBar(
            padding: EdgeInsets.symmetric(
                horizontal: StarThemeData.spacing, vertical: 6),
            isScrollable: true,
            tabs: SgbService.to.shijiTypeList
                .map((e) => Tab(text: e.name))
                .toList(),
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: _listBuild(),
          );
        }),
      ),
    );
  }

  List<ListView> _listBuild() {
    return controller.shijiTypeList
        .map((e) => ListView.builder(
              padding: EdgeInsets.only(bottom: StarThemeData.bottomPadding),
              itemCount: e.length,
              itemBuilder: (context, index) {
                return SongListTile(
                  song: e[index],
                  onTap: (song) => {controller.showDetail(e[index], index)},
                );
              },
            ))
        .toList();
  }
}

class ShijiTypeDirWidget extends StatefulWidget {
  const ShijiTypeDirWidget({super.key});

  @override
  State<ShijiTypeDirWidget> createState() => _ShijiTypeDirWidgetState();
}

class _ShijiTypeDirWidgetState extends State<ShijiTypeDirWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: SgbService.to.shijiTypeList
          .map((e) => ListTile(
                title: Text(e.name),
                onTap: () {
                  DefaultTabController.maybeOf(context)?.animateTo(
                    SgbService.to.shijiTypeList.indexOf(e),
                  );
                  Navigator.pop(context);
                },
              ))
          .toList(),
    );
  }
}
