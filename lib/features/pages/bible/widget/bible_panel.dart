import 'package:flutter/material.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/features/pages/bible/module/bible_dict.dart';
import 'package:m/features/pages/bible/module/bible_panel_vo.dart';
import 'package:m/plugins/star_provider/index.dart';
import 'package:m/shared/widgets/loading.dart';

extension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => (theme.brightness == Brightness.dark);
}

Border _gridBorder(int index) {
  return Border(
      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
      top: index < 4
          ? BorderSide(color: Colors.grey.withOpacity(0.2))
          : BorderSide.none,
      right: BorderSide(
        color: Colors.grey.withOpacity(0.2),
      ));
}

class BiblePanel extends StatefulWidget {
  const BiblePanel({super.key});
  @override
  State<BiblePanel> createState() => _BiblePanelState();
}

class _BiblePanelState extends State<BiblePanel>
    with SingleTickerProviderStateMixin {
  late TabController controller = TabController(length: 3, vsync: this);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();

    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              if (controller.index == 0) {
                return const Text('目录');
              }
              if (controller.index == 1) {
                return Text('${bibleController.volumnSNFullName}');
              }
              return Text(
                  '${bibleController.volumnSNFullName}${bibleController.chapterSN}');
            }),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (!bibleController.mounted) {
            return const Center(
              child: LoadingWidget(),
            );
          }

          final tabs = _buildTabs(context);
          final tabViews = _buildTabViews(context);

          return DefaultTabController(
            key: ValueKey(tabs.length),
            length: tabs.length,
            child: Column(
              children: [
                TabBar(
                  controller: controller,
                  tabs: tabs,
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller,
                    children: tabViews,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();
    List<Widget> tabs = [
      const Tab(text: '卷'),
      const Tab(text: '章'),
      const Tab(text: '节'),
    ];
    if (!bibleController.isEndVerse) {
      tabs.removeAt(2);
    }
    return tabs;
  }

  List<Widget> _buildTabViews(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();
    List<Widget> tabViews = [
      /// 卷
      BibleVolumeSNPanel(
        onTap: () {
          controller.animateTo(1);
        },
      ),

      /// 章
      GridNumberPanel(
        length: bibleController.chapterSNList.length,
        selectIndex: bibleController.chapterSN - 1,
        onTap: (index) {
          bibleController.chapterSN =
              bibleController.chapterSNList[index].ChapterSN;
          if (bibleController.isEndVerse) {
            controller.animateTo(2);
          } else {
            bibleController.verseNumbers = [];
            Navigator.pop(context);
          }
        },
      ),
      GridNumberPanel(
        length: bibleController.verseNumberList.length,
        selectIndex: -1,
        onTap: (index) {
          bibleController.verseNumbers = [index + 1];
          Navigator.pop(context);
        },
      )
    ];

    /// 节
    if(!bibleController.isEndVerse){
      tabViews.removeAt(2);
    }

    return tabViews;
  }
}

/// 卷目录
class BibleVolumeSNPanel extends StatefulWidget {
  final VoidCallback onTap;
  const BibleVolumeSNPanel({super.key, required this.onTap});
  @override
  State<BibleVolumeSNPanel> createState() => _BibleBookPanelState();
}

class _BibleBookPanelState extends State<BibleVolumeSNPanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();
    return CustomScrollView(
      slivers: [
        _buildActions(context),
        if (bibleController.view == DictViewEnum.grid)
          ..._buildGridView(context),
        if (bibleController.view == DictViewEnum.list)
          ..._buildListView(context),
      ],
    );
  }

  /// 操作区域
  Widget _buildActions(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();
    bool isDarkMode = context.isDarkMode;
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Switch(
                activeColor: StarThemeData.primaryColor,
                value: bibleController.isEndVerse,
                onChanged: (value) {
                  bibleController.isEndVerse = value;
                }),
            const Text('目录到节'),
            const Spacer(),
            const Text('视图'),
            IconButton(
                onPressed: () {
                  bibleController.view = DictViewEnum.grid;
                },
                icon: Icon(
                  Icons.grid_view,
                  size: 18,
                  color: bibleController.view == DictViewEnum.grid
                      ? StarThemeData.primaryColor
                      : isDarkMode
                          ? Colors.white
                          : Colors.black,
                )),
            IconButton(
              icon: Icon(
                Icons.list,
                color: bibleController.view == DictViewEnum.list
                    ? StarThemeData.primaryColor
                    : isDarkMode
                        ? Colors.white
                        : Colors.black,
              ),
              onPressed: () {
                bibleController.view = DictViewEnum.list;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 网格视图
  List<Widget> _buildGridView(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();
    bool isDarkMode = context.isDarkMode;
    List<BiblePanelVo> dictListGroup = BibleModel.biblePanelVoList;

    return List.generate(dictListGroup.length * 2, (index) {
      Widget title = SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
          child: Text(
            dictListGroup[index ~/ 2].title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Widget grids = SliverPadding(
        padding: const EdgeInsets.all(12.0),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, cindex) {
              BibleDict bibleDict = dictListGroup[index ~/ 2].dictList[cindex];
              return InkWell(
                onTap: () {
                  bibleController.volumeSN = bibleDict.VolumeSN;
                  widget.onTap();
                },
                child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: _gridBorder(cindex),
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                          color: bibleDict.VolumeSN == bibleController.volumeSN
                              ? StarThemeData.primaryColor
                              : isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bibleDict.ShortName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            bibleDict.FullName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )),
              );
            },
            childCount: dictListGroup[index ~/ 2].dictList.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1 / 1,
          ),
        ),
      );

      if (index == 0) return title;
      if (index == 1) return grids;
      if (index == 2) return title;
      if (index == 3) return grids;
      return Container();
    });
  }

  /// 列表视图
  List<Widget> _buildListView(BuildContext context) {
    BibleModel bibleController = context.watch<BibleModel>();
    bool isDarkMode = context.isDarkMode;
    List<BiblePanelVo> dictListGroup = BibleModel.biblePanelVoList;

    return List.generate(dictListGroup.length * 2, (index) {
      Widget title = SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
          child: Text(
            dictListGroup[index ~/ 2].title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Widget list = SliverPadding(
        padding: const EdgeInsets.all(12.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, cindex) {
              BibleDict bibleDict = dictListGroup[index ~/ 2].dictList[cindex];
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      bibleDict.FullName,
                      style: TextStyle(
                          color: bibleDict.VolumeSN == bibleController.volumeSN
                              ? StarThemeData.primaryColor
                              : isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                    ),
                    onTap: () {
                      bibleController.volumeSN = bibleDict.VolumeSN;
                      widget.onTap();
                    },
                  ),
                  const Divider()
                ],
              );
            },
            childCount: dictListGroup[index ~/ 2].dictList.length,
          ),
        ),
      );

      if (index == 0) return title;
      if (index == 1) return list;
      if (index == 2) return title;
      if (index == 3) return list;
      return Container();
    });
  }
}

class GridNumberPanel extends StatelessWidget {
  final Function(int index) onTap;
  final int length;
  final int selectIndex;
  const GridNumberPanel(
      {super.key,
      required this.onTap,
      required this.length,
      required this.selectIndex});
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1 / 1,
      ),
      itemCount: length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            onTap(index);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: _gridBorder(index),
            ),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(
                  color: selectIndex == index
                      ? StarThemeData.primaryColor
                      : isDarkMode
                          ? Colors.white
                          : Colors.black),
            ),
          ),
        );
      },
    );
  }
}
