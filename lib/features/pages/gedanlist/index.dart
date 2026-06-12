import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';

import 'package:m/features/pages/gedanlist/controller.dart';
import 'package:m/shared/widgets/down_pull_refresh.dart';

class GeDanListPage extends GetWidget<GeDanListController> {
  const GeDanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DownPullRefresn(
      onRefresh: () async {
        await controller.refresh();
        Toast.showToast('刷新成功'.tr);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('歌单详情'.tr),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(22),
              child: Obx(() => Text(controller.song.value?.name ?? '歌单详情'.tr))),
          actions: [
            // 权限按钮
            Obx(() {
              if (controller.hasPer){
                return IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 32,
                  ),
                  onPressed: () {
                    controller.addItem();
                  },
                );}
              return const SizedBox();
            }),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                controller.shareUrl();
              },
            ),
            IconButton(onPressed: () {
                controller.copyId();
            }, icon: const Icon(Icons.copy))
          ],
        ),
        body: Obx(() {
          if (controller.loading.value) {
            return Utils.loading();
          }
          if (controller.list.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(IconUtil.empty,
                    size: 68,
                    color: StarThemeData.primaryColor.withOpacity(0.5)),
                SizedBox(height: StarThemeData.spacing),
                TextButton.icon(
                    label: Text('添加'.tr),
                    onPressed: () {
                      controller.addItem();
                    },
                    icon: const Icon(Icons.add))
              ],
            ));
          }
          return SongListDetailIist(controller: controller);
        }),
      ),
    );
  }
}

class SongListDetailIist extends StatefulWidget {
  const SongListDetailIist({
    super.key,
    required this.controller,
  });

  final GeDanListControllerAbs controller;

  @override
  State<SongListDetailIist> createState() => _SongListDetailIistState();
}

class _SongListDetailIistState extends State<SongListDetailIist> {

  
  @override
  Widget build(BuildContext context) {
    if (widget.controller.list.isEmpty) {
      return Center(
        child: Icon(IconUtil.empty,
            size: 68, color: StarThemeData.primaryColor.withOpacity(0.5)),
      );
    }
    return Obx(() => ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            widget.controller.onReorder(oldIndex, newIndex);
          },
          itemCount: widget.controller.list.length,
          itemBuilder: (context, index) {
            return Container(
              key: Key(index.toString()),
              child: ListTile(
                title: Text(widget.controller.list[index]?.mulu ?? '歌曲'.tr),
                subtitle:
                    Text(widget.controller.list[index]?.shijiName ?? '未知'.tr),
                onTap: () =>
                    widget.controller.toPlayer(widget.controller.list[index]),
                leading: widget.controller.hasPer ?
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.drag_indicator,
                      )):null,
                trailing:  Obx((){

                  if(!widget.controller.hasPer ){
                    return const SizedBox();
                  }
                  return  PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18),
                            SizedBox(
                              width: StarThemeData.spacing,
                            ),
                            Text('删除'.tr),
                          ],
                        ),
                        onTap: () {
                          widget.controller
                              .delItem(widget.controller.list[index]!.id);
                        },
                      ),
                    ];
                  },
                );


                }),
              ),
            );
          },
        ));
  }
}
