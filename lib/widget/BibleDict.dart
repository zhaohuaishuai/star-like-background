 
import 'package:flutter/material.dart';
 
class BibleDict {
  String? title;
  List<ZhangBibleDict>? children;

  BibleDict({this.title, this.children});

  BibleDict.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    children = json["children"] == null
        ? null
        : (json["children"] as List)
            .map((e) => ZhangBibleDict.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    if (children != null) {
      data["children"] = children?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ZhangBibleDict {
  late String title;
  late String shortTitle;
  late String enTitle;
  late String enShortTitle;
  late int total;
  late List<JieBibleDict>? children;

  ZhangBibleDict(
      {required this.title,
      required this.shortTitle,
      required this.enTitle,
      required this.enShortTitle,
      required this.total,
      required this.children});

  ZhangBibleDict.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    shortTitle = json["shortTitle"];
    enTitle = json["enTitle"];
    enShortTitle = json["enShortTitle"];
    total = json["total"];
    children = json["children"] == null
        ? null
        : (json["children"] as List)
            .map((e) => JieBibleDict.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["shortTitle"] = shortTitle;
    data["enTitle"] = enTitle;
    data["enShortTitle"] = enShortTitle;
    data["total"] = total;
    if (children != null) {
      data["children"] = children?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class JieBibleDict {
  String? title;
  int? total;

  JieBibleDict({this.title, this.total});

  JieBibleDict.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    total = json["total"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["total"] = total;
    return data;
  }
}

class BibleData {
  late String title;
  late String zhang;
  late int jie;
  late String data;

  BibleData({required this.title,required this.zhang,required this.jie,required this.data});

  BibleData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    zhang = json['zhang'];
    jie = json['jie'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['zhang'] = this.zhang;
    data['jie'] = this.jie;
    data['data'] = this.data;
    return data;
  }
}


class BibleQueryTab extends StatefulWidget {
  final  void Function(ZhangBibleDict q ) zhangChange;
  final  void Function(ZhangBibleDict q, JieBibleDict z) jieChange;
  final  void Function(ZhangBibleDict q, JieBibleDict z,int j ) change;
  final void Function(bool b)? jieIsShowChange;
  final List<BibleDict> dict;
  final ZhangBibleDict currentZhang;
  final JieBibleDict currentJie;
  final int current ;
  final bool? jieIsShow ;
  final bool isDrakMode;
   BibleQueryTab({Key? key,
    required this.change,
    required this.zhangChange,
    required this.jieChange,
    this.jieIsShowChange,
    required this.dict,
    required this.currentJie,
    required this.currentZhang,
    required this.current,
    required this.isDrakMode,

    this.jieIsShow = true
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BibleQueryTabState();
}

class BibleQueryTabState extends State<BibleQueryTab>
  with TickerProviderStateMixin   {
  late TabController _tabController;
  late List<BibleDict> dict = [];
  ZhangBibleDict? currentZhang;
  JieBibleDict? currentJie;
  int current = 0;
  Color themeColor = Colors.deepPurple;
  Color get bgColor {
    return widget.isDrakMode?Colors.black:Colors.white;
  }
  Color get textColor {
    return widget.isDrakMode?Colors.white:Colors.black;
  }
  Color get themeTextColor {
    return widget.isDrakMode?Colors.deepPurple:Colors.white;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // rootBundle.loadString('assets/json/bible_dict.json').then((data)  {
    //   List<BibleDict>  newDict =  json.decode(data).map<BibleDict>((item){
    //      return BibleDict.fromJson(item);
    //    }).toList();
    //   setState(() {
    //     dict = newDict;
    //     currentZhang = dict[0].children![0];
    //     currentJie = dict[0].children![0].children![0];
    //   });
    // });
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }


  void _changeIndex(int newIndex) {
    _tabController.animateTo(newIndex); // 改变Tab页
  }

  get _tabs {
    if(widget.jieIsShow ?? true){
      return const [
        Tab(text: '卷'),
        Tab(text: '章'),
        Tab(text: '节'),
      ];
    }else{
      return const [
        Tab(text: '卷'),
        Tab(text: '章'),
      ];
    }
  }
  get _tabViews {

    return widget.jieIsShow ?? true? [
      QuanBibleDictWidget(
        bgColor: bgColor,
        textColor: textColor,
        data: widget.dict,
        onTap: (z) {
          widget.zhangChange(z);
          _changeIndex(1);
        },
      ),
      Builder(
          builder: (context) {
            ZhangBibleDict currentZhang = widget.currentZhang;
            return ZhangBibleWidget(
              bgColor: bgColor,
              textColor: textColor,
              data: currentZhang,
              onTap: (j) {
                widget.jieChange(currentZhang,j);
                _changeIndex(2);
              },
            );
          }
      ),
      Builder(
          builder: (context) {
            ZhangBibleDict currentZhang = widget.currentZhang;
            JieBibleDict currentJie = widget.currentJie;
            return JieBibleWidget(
                bgColor: bgColor,
                textColor: textColor,
                data: currentJie ,
                onTap: (c) {
                  widget.change(currentZhang,currentJie,c);
                });
          }
      )
    ]: [
      QuanBibleDictWidget(
        bgColor: bgColor,
        textColor: textColor,
        data: widget.dict,
        onTap: (z) {
          widget.zhangChange(z);
          _changeIndex(1);
        },
      ),
      Builder(
          builder: (context) {
            ZhangBibleDict currentZhang = widget.currentZhang;
            return ZhangBibleWidget(
              bgColor: bgColor,
              textColor: textColor,
              data: currentZhang,
              onTap: (j) {
                widget.jieChange(currentZhang,j);
                _changeIndex(2);
              },
            );
          }
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabViews.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.isDrakMode?Colors.black:Colors.deepPurple,
          automaticallyImplyLeading: false,
          title: Builder(builder: (context){
            ZhangBibleDict currentZhang = widget.currentZhang;
            JieBibleDict currentJie = widget.currentJie;
            return Row(children: [
               Switch(
                  inactiveThumbColor:Colors.white,
                  activeColor: Colors.red,
                 value: widget.jieIsShow??false, onChanged: (bol){
                  print(bol);
                  _tabController.dispose();
                  _tabController = TabController(length: bol? 3:2, vsync: this);
                  widget.jieIsShowChange!(bol);

               }),
              Text("目录到节",style: TextStyle(fontSize: 10),)

            ],);
          }),
          toolbarHeight: 40,
          bottom: TabBar(
            controller: _tabController,
              indicatorColor:Colors.white,
              labelPadding: const EdgeInsets.all(0),
              tabs: _tabs,
          ),
        ),
        body: SafeArea(child:Builder(
          builder: (context) {
            List<BibleDict> dict = widget.dict;
            if(dict.length == 0){
              return Container();
            }
            return Container(
              color: bgColor,
              child: TabBarView(
                controller: _tabController,
                children: _tabViews,
              ),
            );
          }
        ),)
      ),
    );
  }
}

class QuanBibleDictWidget extends StatefulWidget {
  final List<BibleDict> data;
  final void Function(ZhangBibleDict z)? onTap;
  final bgColor;
  final textColor;
  const QuanBibleDictWidget({Key? key, required this.data, required this.onTap,required this.bgColor,required this.textColor})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => QuanBibleDictStatusWidget();
}

class QuanBibleDictStatusWidget extends State<QuanBibleDictWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> wl = widget.data
        .map((bible) {
          return [
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Padding(
                      padding:  EdgeInsets.all(10),
                      child: Text(bible.title ?? '--',
                          style:  TextStyle(fontSize: 16,color: widget.textColor))),
                ],
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  List<ZhangBibleDict> zhangBibleDictList =
                      bible.children ?? [];
                  ZhangBibleDict zhang = zhangBibleDictList[index];
                  return Material(
                    color:Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.onTap?.call(zhang);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        color: widget.bgColor,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zhang.shortTitle,
                                style:  TextStyle(
                                  fontSize: 14,
                                  color: widget.textColor
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(zhang.title,
                                  style:  TextStyle(fontSize: 10,color: widget.textColor)),
                            ]),
                      ),
                    ),
                  );
                },
                childCount: bible.children?.length ?? 0,
              ),
            ),
          ];
        })
        .toList()
        .expand((element) => element)
        .toList();

    return CustomScrollView(
      slivers: wl,
    );
  }
}

class ZhangBibleWidget extends StatefulWidget {
  final void Function(JieBibleDict j)? onTap;
  final ZhangBibleDict data;
  final bgColor;
  final textColor;
  ZhangBibleWidget({Key? key, required this.data, required this.onTap,required this.bgColor,required this.textColor})
      : super(key: key);

  State<StatefulWidget> createState() => ZhangBibleWidgetState();
}

class ZhangBibleWidgetState extends State<ZhangBibleWidget>{
  @override
  Widget build(BuildContext context) {

    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              List<JieBibleDict> jieBibleDictList = widget.data.children ?? [];
              JieBibleDict jie = jieBibleDictList[index];
              return InkWell(
                onTap: () {
                  widget.onTap!(jie);
                },
                child: Container(
                  color: widget.bgColor,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jie.title.toString(),
                            style:  TextStyle(
                              fontSize: 14,
                              color: widget.textColor
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                        ]),
                  ),
                ),
              );
            },
            childCount: widget.data.children?.length ?? 0,
          ),
        )
      ],
    );
  }
}


class JieBibleWidget extends StatefulWidget {
  final void Function(int index)? onTap;
  final JieBibleDict data;
  final bgColor;
  final textColor;
  JieBibleWidget({Key? key, required this.data, required this.onTap,required this.bgColor,required this.textColor})
      : super(key: key);

  State<StatefulWidget> createState() => JieBibleWidgetState();
}


class JieBibleWidgetState extends State<JieBibleWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  widget.onTap!(index + 1);
                },
                child: Container(
                  color: widget.bgColor,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (index + 1).toString(),
                            style:  TextStyle(
                              fontSize: 14,
                              color: widget.textColor
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                        ]),
                  ),
                ),
              );
            },
            childCount: widget.data.total ?? 0,
          ),
        )
      ],
    );
  }
}