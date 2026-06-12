import 'dart:convert';
import 'dart:io';
import 'package:flutter_html/flutter_html.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Shine_like_a_star/widget/BibleDict.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as DDio;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../config/color.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/bookMark.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({Key? key}) : super(key: key);
  State<StatefulWidget> createState() => BiblePageState();
}

class BiblePageState extends State<BiblePage> {
  late ZhangBibleDict zhangBibleDict = ZhangBibleDict(
      title: '创世纪',
      shortTitle: '创',
      enTitle: 'Genesis',
      enShortTitle: 'Gen',
      total: 50,
      children: []);
  late JieBibleDict jieBibleDict = JieBibleDict(title: '1', total: 31);
  late int current = 0;
  // late String parameter = "创1";
  late List<int> selectIndex = [];
  late List<BibleData> bibleList = [];
  late List<BibleDict> dict = [];
  late bool loading = false;
  late bool jieIsShow = true;
  final ItemScrollController itemScrollController = ItemScrollController();
  late Database? database;
  BookMarkUtil bookMarkUtil = BookMarkUtil();
  final storage = GetStorage();
  String localIsDrakMode = 'localIsDrakMode';
  String LOCAL_BIBLE_Q = 'bible_q';
  String LOCAL_BIBLE_Z = 'bible_Z';
  String LOCAL_BIBLE_J = 'bible_j';
  String LOCAL_JIE_IS_SHOW = 'LOCAL_JIE_IS_SHOW';
  String get params {
    return zhangBibleDict.shortTitle + jieBibleDict.title.toString();
  }

  bool isDrakMode = false;
  Color themeColor = Colors.deepPurple;
  Color get bgColor {
    return isDrakMode ? Colors.black : Colors.white;
  }

  Color get textColor {
    return isDrakMode ? Colors.white : Colors.black;
  }

  Color get themeTextColor {
    return isDrakMode ? Colors.deepPurple : Colors.white;
  }

  @override
  void initState() {
    super.initState();
    isDrakMode = storage.read<bool?>(localIsDrakMode) ?? false;
    jieIsShow = storage.read<bool?>(LOCAL_JIE_IS_SHOW) ?? false;
    if (storage.read(LOCAL_BIBLE_Q) != null) {
      Map<String, dynamic> tmp = storage.read(LOCAL_BIBLE_Q);
      zhangBibleDict = ZhangBibleDict.fromJson(tmp);
    }
    if (storage.read(LOCAL_BIBLE_Z) != null) {
      jieBibleDict = JieBibleDict.fromJson(
          storage.read(LOCAL_BIBLE_Z) as Map<String, dynamic>);
    }
    if (storage.read(LOCAL_BIBLE_J) != null) {
      current = storage.read<int>(LOCAL_BIBLE_J)!;
    }
    loadBibleDb().then((value) {
      print("执行查询");
      handleGetBibleData();
    });
  }

  void _scrollToIndex(int index) async {
    await Future.delayed(Duration(milliseconds: 100));
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<List<BibleData>?> handleGetBibleData() async {
    setState(() {
      loading = true;
      selectIndex = [];
    });
    List<BibleDict>? data;
    try {
      if (this.database != null) {
        print("查询的参数" + params);
        var separate = separateStringAndNumber(params);
        String shortName = separate[0];
        int chapterSn = separate[1] as int;

        data = (await loadLocalDbBibleData(
                shortName, chapterSn, this.database as Database))
            ?.cast<BibleDict>();
      } else {
        print("加载远程数据库");
        data = (await handleGetRemoteBibleData(params)).cast<BibleDict>();
      }

      if (data != null) {
        setState(() {
          bibleList = data?.cast<BibleData>() ?? [];
          loading = false;
          //jieIsShow &&
          print("current-->" + current.toString());
          if ( current - 1 > -1) {
            selectIndex.add(current - 1);
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _scrollToIndex(current - 1);
            });
          } else {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _scrollToIndex(0);
            });
          }
          // if (!jieIsShow) {
          //   SchedulerBinding.instance.addPostFrameCallback((_) {
          //     _scrollToIndex(0);
          //   });
          // }
          // 存储记忆
          storage.write(LOCAL_BIBLE_Q, zhangBibleDict.toJson());
          storage.write(LOCAL_BIBLE_Z, jieBibleDict.toJson());
          storage.write(LOCAL_BIBLE_J, current);
        });
      } else {
        setState(() {
          bibleList = [];
          loading = false;
        });
      }
    } catch (err) {
      print("报错最终" + err.toString());
    }
  }

  List<dynamic> separateStringAndNumber(String input) {
    String stringPart = '';
    String numberPart = '';
    for (int i = 0; i < input.length; i++) {
      if (int.tryParse(input[i]) != null) {
        numberPart += input[i];
      } else {
        stringPart += input[i];
      }
    }
    return [stringPart, int.parse(numberPart)];
  }

  /**
   * 加载远程数据
   */
  Future<List<BibleData>> handleGetRemoteBibleData(String parameter) async {
    DDio.Dio dio = DDio.Dio();
    var url = "https://star.top237.top/api/book?id=${parameter}";
    print(parameter);

    try {
      DDio.Response<dynamic> res = await dio.get(url);
      if (res.data != null && res.data['data'] != null) {
        List<BibleData> data = res.data['data'].map<BibleData>((item) {
          return BibleData.fromJson(item);
        }).toList();

        return data;
      } else {
        setState(() {
          bibleList = [];
          loading = false;
        });
        return [];
      }
    } catch (error) {
      print("加载出错：${error}");
      setState(() {
        bibleList = [];
        loading = false;
      });
      return [];
    }
  }

  /**
   * 加载本地数据库
   */
  Future<List<BibleData>?> loadLocalDbBibleData(
      String shortName, int chapterSn, Database db) async {
    List<Map>? list = (await db.rawQuery(
            "select * from Bible where VolumeSN = (select SN from BibleId where ShortName = '$shortName') and ChapterSN = $chapterSn;"))
        ?.cast<Map>();

    return list?.map<BibleData>((item) {
      return BibleData(
          title: shortName,
          jie: item['VerseSN'],
          data: item['Lection'],
          zhang: chapterSn.toString());
    }).toList();
  }

  /**
   * 初始化加载数据和数据库
   */
  Future<bool> loadBibleDb() async {
    String data = await rootBundle.loadString('assets/json/bible_dict.json');
    List<BibleDict> newDict = json.decode(data).map<BibleDict>((item) {
      return BibleDict.fromJson(item);
    }).toList();
    setState(() {
      dict = newDict;
      // zhangBibleDict = dict[0].children![0];
      // jieBibleDict = dict[0].children![0].children![0];
    });
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'bible.db');
    print("数据库目录-->" + documentsDirectory.path);
    // 检查数据库是否存在
    if (await File(path).exists()) {
      // print("DB exists");
      this.database = await openReadOnlyDatabase(path);
      return true;
    } else {
      // 如果数据库不存在，将 assets 中的数据库文件复制到设备的目录
      var url =
          'https://oss.top237.top/npm/static/sqllite/bible.db';
      var dio = Dio();
      // 使用 Dio 开始下载
      try {
        print("开始下载db文件");
        await dio.download(url, path);
        print("下载完成");
        this.database = await openReadOnlyDatabase(path);
        return true;
      } catch (e) {
        print('Download error: $e');
        return false;
      }
    }
  }

  /**
   * 下一章
   */
  handleNextZhang() {
    int cz = int.parse(jieBibleDict.title as String);
    int total = zhangBibleDict.total;
    if (cz < total) {
      setState(() {
        jieBibleDict = JieBibleDict(title: (cz + 1).toString(), total: total);
        current = 0;
        handleGetBibleData();
      });
    }
  }

  /**
   * 上一章
   */
  handlePreZhang() {
    int cz = int.parse(jieBibleDict.title as String);
    int total = zhangBibleDict.total;
    int pre = cz - 1;
    if (pre > 0) {
      setState(() {
        jieBibleDict = JieBibleDict(title: (pre).toString(), total: total);
        current = 0;
        handleGetBibleData();
      });
    }
  }

  /**
   * 章节选择器变化
   */
  handleChange({ZhangBibleDict? q, JieBibleDict? z, int? j}) {
    setState(() {
      if (q != null) {
        zhangBibleDict = q;
        // storage.write(LOCAL_BIBLE_Q, q.toJson());
      }

      if (z != null) {
        jieBibleDict = z;
        // storage.write(LOCAL_BIBLE_Z, z.toJson());
      }
      if (j != null) {
        current = j;
        // storage.write(LOCAL_BIBLE_J, j);
      }
    });
  }

  /**
   * 打开书签
   */
  openBookmark(BuildContext context) {
    //打开一个底部弹窗
    print("打开书签");
    showModalBottomSheet(
        backgroundColor: isDrakMode ? Colors.black : Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
          //这里是modal的边框样式
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return BookMark(
              color:isDrakMode ? Colors.deepPurple : Colors.black,
              bookMarkUtil:bookMarkUtil,
              change: (ZhangBibleDict q, JieBibleDict z,int j){
                handleChange(q:q,z:z,j:j);
                handleGetBibleData();
                Navigator.of(context).pop();
              },
              bibleList: dict,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDrakMode ? Colors.black : Colors.deepPurple,
        automaticallyImplyLeading: false,
        // leading: Container(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                zhangBibleDict.title +
                    jieBibleDict.title.toString() +
                    ((jieIsShow && current > 0)
                        ? ":" + current.toString()
                        : ''),
                style: TextStyle(color: themeTextColor)),
            Row(
              children: [
                Text(
                  "夜间模式",
                  style: TextStyle(color: themeTextColor, fontSize: 16),
                ),
                Switch(
                    activeColor: Colors.deepPurple,
                    value: isDrakMode,
                    onChanged: (value) {
                      setState(() {
                        isDrakMode = value;
                        storage.write(localIsDrakMode, value);
                      });
                    }),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          if (selectIndex.length == 0) {
            return Container();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
              tooltip: "添加书签",
              backgroundColor: themeColor,
              onPressed: () async {
                try {
                    await bookMarkUtil.insert(zhangBibleDict,jieBibleDict,selectIndex.last + 1);
                    Get.snackbar("提示", "添加书签成功",
                        duration: Duration(seconds: 1),
                        icon: Icon(
                          Icons.notifications,
                          color: textColor,
                        ),
                        shouldIconPulse: true,
                        backgroundColor: bgColor,
                        colorText: textColor);
                } catch (error) {

                  Get.snackbar("提示",error as String,
                      duration: Duration(seconds: 1),
                      icon: Icon(
                        Icons.error,
                        color: textColor,
                      ),
                      shouldIconPulse: true,
                      backgroundColor: bgColor,
                      colorText: textColor);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                  ),
                  Text("书签")
                ],
              )),
              SizedBox(height:12),
              FloatingActionButton(
              backgroundColor: themeColor,
              tooltip: "复制",
              onPressed: () async {
                try {
                  String text = selectIndex
                      .map((int e) {
                        return "${bibleList[e].data.trimLeft()} (${zhangBibleDict!.title}${jieBibleDict.title}:${e + 1})";
                      })
                      .toList()
                      .join("\n");
                  Clipboard.setData(new ClipboardData(text: text));
                  Get.snackbar("提示", "复制失败",
                      duration: Duration(seconds: 1),
                      icon: Icon(
                        Icons.notifications,
                        color: textColor,
                      ),
                      shouldIconPulse: true,
                      backgroundColor: bgColor,
                      colorText: textColor);
                } catch (error) {
                  Get.snackbar("提示", "复制失败",
                      duration: Duration(seconds: 1),
                      icon: Icon(
                        Icons.error,
                        color: textColor,
                      ),
                      shouldIconPulse: true,
                      backgroundColor: bgColor,
                      colorText: textColor);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.copy,
                  ),
                  Text("复制")
                ],
              ))
            ],
          );
        },
      ),
      drawer: Drawer(
        backgroundColor: AppColor.appBackgroundColor,
        child: Builder(builder: (context) {
          return BibleQueryTab(
              isDrakMode: isDrakMode,
              dict: dict,
              current: this.current,
              currentZhang: this.zhangBibleDict,
              currentJie: this.jieBibleDict,
              jieIsShow: this.jieIsShow,
              change: (q, z, j) {
                handleChange(q: q, z: z, j: j);
                Scaffold.of(context).closeDrawer();
                handleGetBibleData();
              },
              zhangChange: (ZhangBibleDict q) {
                handleChange(q: q);
              },
              jieChange: (ZhangBibleDict q, JieBibleDict z) {

                if (!jieIsShow) {
                  handleChange(q: q, z: z,j:0);
                  Scaffold.of(context).closeDrawer();
                  handleGetBibleData();
                }else{
                  handleChange(q: q, z: z);
                }
              },
              jieIsShowChange: (bol) {
                setState(() {
                  jieIsShow = bol;
                  storage.write(LOCAL_JIE_IS_SHOW, bol);
                  if (!bol) {
                    handleChange(j: -1);
                  }
                });
              });
        }),
      ),
      body: Builder(
        builder: (context) {
          if (loading) {
            return Container(
              color: bgColor,
              child: Center(
                  child: Container(
                      color: bgColor,
                      height: 130,
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '加载中...',
                            style: TextStyle(color: textColor),
                          )
                        ],
                      ))),
            );
          }
          return Container(
            color: bgColor,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            child: ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemCount: bibleList.length,
                itemBuilder: (context, index) {
                  BibleData bibleData = bibleList[index];
                  return InkWell(
                      onTap: () {
                        HapticFeedback.vibrate();
                        setState(() {
                          if (selectIndex.indexOf(index) > -1) {
                            selectIndex.remove(index);
                            if (selectIndex.length == 0) {
                              storage.write(LOCAL_BIBLE_J, -1);
                            }
                          } else {
                            selectIndex.add(index);
                          }
                        });
                      },
                      child: Text(
                        (index + 1).toString() +
                                ' ' +
                                bibleData.data.trimLeft() ??
                            '',
                        style: TextStyle(
                            fontSize: 24,
                            height: 1.8,
                            decoration: selectIndex.indexOf(index) > -1
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            color: textColor),
                      ));
                }),
          );
        },
      ),
      bottomNavigationBar: Builder(builder: (context) {
        return BottomAppBar(
          child: Container(
            color: bgColor,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      handlePreZhang();
                    },
                    child: Text(
                      "上一章",
                      style: TextStyle(color: themeColor),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        handleNextZhang();
                      },
                      child: Text(
                        "下一章",
                        style: TextStyle(color: themeColor),
                      )),
                  TextButton(
                      onPressed: () {
                        // handleNextZhang();
                        openBookmark(context);
                      },
                      child: Text(
                        "书签",
                        style: TextStyle(color: themeColor),
                      )),
                  TextButton.icon(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: themeColor,
                      ),
                      label: Text("目录", style: TextStyle(color: themeColor)))
                ]),
          ),
        );
      }),
    );
  }
}

class BookMark extends StatefulWidget {
  Color color;
  BookMarkUtil bookMarkUtil ;
  void Function(ZhangBibleDict q, JieBibleDict z,int j)? change;
  late List<BibleDict> bibleList;
  BookMark({
    Key? key,
    required this.bookMarkUtil,
    this.change,
    required this.bibleList,
    required this.color,
  }) : super(key: key);
  State<StatefulWidget> createState() => BookMarkState();
}

class BookMarkState extends State<BookMark> {

  late List<Map> bookMarkList = List.empty();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    List<Map> list = await widget.bookMarkUtil.queryList();
    setState(() {
      bookMarkList = list;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: EdgeInsets.only(top: 0, bottom: 24, left: 10, right: 10),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.all(20),child: Text("书签管理",style: TextStyle(color: widget.color))),
          Expanded(child:Builder(
            builder: (context) {
              
              if(bookMarkList.length == 0){
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/emty_day.png",width: 180,),
                      Text("暂无数据",style: TextStyle(color:widget.color),),
                      Text("请选择一条经文点击添加书签按钮",style: TextStyle(color:widget.color))
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                  itemBuilder: (context, index) {
                    return Dismissible(
                        child: ListTile(
                            onTap: (){
                              String str = bookMarkList[index][widget.bookMarkUtil.columnZDict];

                            // print(json.decode(str));
                            ZhangBibleDict z =  ZhangBibleDict.fromJson(jsonDecode(bookMarkList[index][widget.bookMarkUtil.columnZDict]));
                            JieBibleDict je = JieBibleDict.fromJson(jsonDecode(bookMarkList[index][widget.bookMarkUtil.columnJDict]));
                              int j =int.parse( bookMarkList[index][widget.bookMarkUtil.columnIndex]);
                              widget?.change!(
                                  z,je,j
                              );
                            },
                            title: Text(bookMarkList[index]['title'],style: TextStyle(color: widget.color), ),
                            subtitle: Text("${bookMarkList[index]['create_date'].toString()} 创建",style: TextStyle(color: widget.color)),
                        ),
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          try {
                            widget.bookMarkUtil.delete(bookMarkList[index]['_id']);
                            init();
                            Get.showSnackbar(
                                GetSnackBar(
                                  duration: Duration(seconds: 1),
                                  message: "删除成功",
                                )
                            );
                          }catch(err){
                            Get.showSnackbar(
                                GetSnackBar(
                                  duration: Duration(seconds: 1),
                                  message: "删除失败",
                                )
                            );
                          }

                        },
                        background: Container(
                          color: Colors.red,
                        ));
                  },
                  itemCount: bookMarkList.length);
            }
          )
          )
        ],
      ),
    );
  }
}



