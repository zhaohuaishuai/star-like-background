// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/bible.dart';
import 'package:m/features/pages/bible/bible_dict.dart'
    show ZhangBibleDict, JieBibleDict;

import 'package:m/features/pages/bible/bible_player.dart';
import 'package:m/features/pages/bible/bible_scroll_view.dart';
import 'package:m/features/pages/bible/book_mark_util.dart';
import 'package:m/features/pages/bible/module/bible_content.dart';
import 'package:m/features/pages/bible/module/bible_dict.dart';
import 'package:m/features/pages/bible/module/bible_panel_vo.dart';
import 'package:m/features/pages/bible/module/bible_search_content.dart';
import 'package:m/features/pages/bible/module/chapter.dart';
import 'package:m/features/pages/bible/widget/book_mark.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

enum DictViewEnum { grid, list }

class BibleModel extends ChangeNotifier {
  final Map<String, dynamic>? arguments;
  GetStorage getStorage = GetStorage();

  /// 字体大小
  static const String fontSizeKey = 'bible_fontSize';

  /// 书卷编号
  static const String volumeSNKey = 'bible_volumeSN';

  /// 章节编号
  static const String chapterSNKey = 'bible_chapterSN';

  /// 是否初始化完成
  bool inited = false;
  final BibleProvider api = BibleProvider();
  BibleModel({this.arguments}) {
    init();
  }

  init() async {
    inited = false;
    try {
      await loadData();

      _fontSize = await getStorage.readDouble(fontSizeKey) ?? 24;
      if (arguments != null) {
        String? id = arguments?['id'];
        debugPrint('bible model init id:$id');
        if (id != null) {
          final (v, c, vss) = transform(id, dictList: dictList);
          debugPrint('bible model init id:$id v:$v c:$c vss:$vss');
          _volumeSN = v;
          _chapterSN = c;
          _verseNumbers = vss;
          if (vss.isNotEmpty) {
            scrollToIndex(vss.first - 1);
          }
          return;
        }
      }
      _volumeSN = await getStorage.readInt(volumeSNKey) ?? 1;
      _chapterSN = await getStorage.readInt(chapterSNKey) ?? 1;
    } catch (err) {
      debugPrint('bible model init error:$err');
    } finally {
      inited = true;
    }
  }

  BiblePlayer biblePlayer = BiblePlayer();

  static const double fontSizeMin = 12;
  static const double fontSizeMax = 40;

  double _fontSize = 24;
  double get fontSize => _fontSize;
  set fontSize(double value) {
    if (value > fontSizeMax) {
      value = fontSizeMax;
    }
    if (value < fontSizeMin) {
      value = fontSizeMin;
    }
    _fontSize = value;
    getStorage.writeDouble(fontSizeKey, value);
    notifyListeners();
  }

  /// 解析圣经经文ID，格式可能是：
  /// - "创1"（创世记第1章）
  /// - "创1:1"（创世记第1章第1节）
  /// - "创1:1-2"（创世记第1章第1-2节）
  /// - 支持通过ShortName、FullName或PinYin进行匹配
  /// 参数：
  /// - id: 圣经经文ID
  /// - dictList: BibleDict列表，用于动态查找书卷简称对应的卷号
  /// 返回元组：(书卷编号, 章节编号, 节编号)
  static (int, int, List<int>) transform(String id,
      {required List<BibleDict> dictList}) {
    // 用于存储解析结果
    int volumeSN = 1; // 默认书卷编号
    int chapterSN = 1; // 默认章节编号
    List<int> verseSN = [1]; // 默认节编号

    // 如果id为空，直接返回默认值
    if (id.isEmpty) {
      return (volumeSN, chapterSN, verseSN);
    }

    try {
      // 提取书卷简称（如"创"）
      String bookAbbr = '';
      int i = 0;
      while (i < id.length && !RegExp(r'\d').hasMatch(id[i])) {
        bookAbbr += id[i];
        i++;
      }

      // 优先从传入的dictList中动态查找书卷编号
      if (dictList.isNotEmpty) {
        // 尝试通过ShortName、FullName或PinYin进行匹配
        final bibleDict =
            findBibleDictByAnyName(dictList, bookAbbr) ?? dictList.first;
        volumeSN = bibleDict.VolumeSN;
      }

      // 提取章节和节的信息
      String remaining = id.substring(i);

      if (remaining.isNotEmpty) {
        // 处理章节信息
        RegExp splitRegExp = RegExp(r':|：');
        List<String> parts = remaining.split(splitRegExp);
        if (parts.isNotEmpty && parts[0].isNotEmpty) {
          chapterSN = int.tryParse(parts[0]) ?? 1;
        }

        // 处理节信息
        if (parts.length > 1 && parts[1].isNotEmpty) {
          // 处理节范围（如"1-2"）
          List<String> verseParts = parts[1].split('-');
          if (verseParts.isNotEmpty && verseParts[0].isNotEmpty) {
            int startVerse = int.tryParse(verseParts[0]) ?? 1;
            verseSN = [startVerse];

            // 如果有范围，生成从起始节到结束节的所有节号
            if (verseParts.length > 1 && verseParts[1].isNotEmpty) {
              int endVerse = int.tryParse(verseParts[1]) ?? startVerse;
              if (endVerse >= startVerse) {
                verseSN = List.generate(
                    endVerse - startVerse + 1, (index) => startVerse + index);
              } else {
                // 如果结束节小于起始节，交换它们
                verseSN = List.generate(
                    startVerse - endVerse + 1, (index) => endVerse + index);
              }
            }
          }
        }
      }
    } catch (e) {
      // 如果解析出错，使用默认值
      debugPrint('解析圣经ID出错: $e');
    }

    return (volumeSN, chapterSN, verseSN);
  }

  /// 在dictList中查找匹配指定名称的圣经书卷
  /// 尝试通过ShortName、FullName或PinYin进行匹配
  /// 如果找不到匹配项，则返回null
  static BibleDict? findBibleDictByAnyName(
      List<BibleDict> dictList, String name) {
    // 优先尝试完全匹配
    final exactMatch = dictList.firstWhereOrNull((dict) =>
        dict.ShortName == name || dict.FullName == name || dict.PinYin == name);

    if (exactMatch != null) {
      return exactMatch;
    }

    // 如果没有完全匹配，尝试部分匹配
    final partialMatch = dictList.firstWhereOrNull((dict) =>
        dict.ShortName.contains(name) ||
        dict.FullName.contains(name) ||
        dict.PinYin.contains(name));

    return partialMatch;
  }

  static Database? db;

  /// 卷
  int _volumeSN = 1;
  int get volumeSN => _volumeSN;
  set volumeSN(int value) {
    if (_volumeSN != value) {
      _volumeSN = value;
      chapterSN = 1;
      verseNumbers = [];
      getStorage.writeInt(volumeSNKey, value);
      notifyListeners();
    }
  }

  String? get volumnSNFullName {
    if (!mounted) return null;
    return dictList
        .firstWhere((element) => element.VolumeSN == volumeSN)
        .FullName;
  }

  BibleDict? get currentBibleDict {
    if (!mounted) return null;
    return dictList.firstWhere((element) => element.VolumeSN == volumeSN);
  }

  /// 章
  int _chapterSN = 1;
  int get chapterSN => _chapterSN;
  set chapterSN(int value) {
    if (_chapterSN != value) {
      if (value > chapterSNList.length) {
        if (volumeSN < dictList.length) {
          volumeSN++;
          value = 1;
        } else {
          Toast.showToast('最后一节了');
          return;
        }
      }
      if (value < 1) {
        value = 1;
        if (volumeSN > 1) {
          volumeSN--;
        } else {
          Toast.showToast('最前面一节了');
        }
      }
      _chapterSN = value;
      verseNumbers = [];

      getStorage.writeInt(chapterSNKey, value);
      notifyListeners();
    }
  }

  Chapter? get currentChapter => currentBibleDict?.children
      .firstWhere((element) => element.ChapterSN == chapterSN);

  List<Chapter> get chapterSNList {
    if (!mounted) return [];
    return dictList
        .firstWhere((element) => element.VolumeSN == volumeSN)
        .children;
  }

  List<int> get verseNumberList {
    if (!mounted) return [];
    int verseNumber = chapterSNList
        .firstWhere((element) => element.ChapterSN == chapterSN)
        .VerseNumber;
    return List.generate(verseNumber, (index) => index + 1);
  }

  /// 节选择索引列表
  List<int> _verseNumbers = [];
  List<int> get verseNumbers => _verseNumbers;
  set verseNumbers(List<int> value) {
    if (_verseNumbers != value) {
      _verseNumbers = value;
      notifyListeners();
    }
  }

  selectVerseNumber(int value) {
    if (!_verseNumbers.contains(value)) {
      _verseNumbers.add(value);
    } else {
      _verseNumbers.remove(value);
    }
    notifyListeners();
  }

  bool get isSelect => verseNumbers.isNotEmpty;

  /// 目录视图数据
  static List<BiblePanelVo> biblePanelVoList = [];

  /// 是否挂载
  bool _mounted = false;
  bool get mounted => _mounted;

  set mounted(bool value) {
    _mounted = value;
    notifyListeners();
  }

  /// 字典列表
  static List<BibleDict> _dictList = [];
  static List<BibleDict> get dictList => _dictList;

  /// 字典列表
  static set dictList(List<BibleDict> value) {
    _dictList = value;
    List<BiblePanelVo> list = [];
    list.add(BiblePanelVo(
        title: '旧约',
        dictList: dictList.where((element) => element.NewOrOld == 0).toList()));
    list.add(BiblePanelVo(
        title: '新约',
        dictList: dictList.where((element) => element.NewOrOld == 1).toList()));
    biblePanelVoList = list;
  }

  /// 目录到节
  bool _isEndVerse = true;
  bool get isEndVerse => _isEndVerse;
  set isEndVerse(bool value) {
    _isEndVerse = value;
    notifyListeners();
  }

  // 视图
  DictViewEnum _view = DictViewEnum.grid;
  DictViewEnum get view => _view;
  set view(DictViewEnum value) {
    _view = value;
    notifyListeners();
  }

  /// 初始化数据时加载
  Future<void> loadData() async {
    BibleModel.db ??= await BibleModel.loadBibleDb();
    dictList = await api.getBibleDictList();
    mounted = true;
  }

  /// 加载本地数据库
  Future<List<BibleContent>?> loadLocalDbBibleData(
      int VolumeSN, int ChapterSN) async {
    debugPrint('loadLocalDbBibleData: $VolumeSN $ChapterSN');
    List<Map>? list = (await db?.rawQuery(
            'select * from Bible where VolumeSN = $VolumeSN and ChapterSN = $ChapterSN;'))
        ?.cast<Map>();

    return list?.map<BibleContent>((item) {
      return BibleContent(
          ID: item['ID'],
          VolumeSN: VolumeSN,
          ChapterSN: ChapterSN,
          VerseSN: item['VerseSN'],
          Lection: item['Lection']);
    }).toList();
  }

  /// 加载整卷
  Future<List<List<BibleContent>>> loadLocalDbBibleDataVolume(
      int VolumeSN) async {
    List<Map>? list =
        (await db?.rawQuery('select * from Bible where VolumeSN = $VolumeSN;'))
            ?.cast<Map>();
    List<BibleContent>? bibleContentList = list?.map<BibleContent>((item) {
      return BibleContent(
          ID: item['ID'],
          VolumeSN: VolumeSN,
          ChapterSN: item['ChapterSN'],
          VerseSN: item['VerseSN'],
          Lection: item['Lection']);
    }).toList();
    if (bibleContentList == null) return [];

    bibleContentList.sort((a, b) => a.ChapterSN.compareTo(b.ChapterSN));
    List<List<BibleContent>> volumeList = [];
    for (int i = 0; i < bibleContentList.length; i++) {
      if (volumeList.length < bibleContentList[i].ChapterSN) {
        volumeList.add([]);
      }
      volumeList[bibleContentList[i].ChapterSN - 1].add(bibleContentList[i]);
    }

    return volumeList;
  }

  Future<List<BibleContent>?> get bibleContents async {
    if (!inited) {
      return [];
    }
    return await loadLocalDbBibleData(volumeSN, chapterSN);
  }

  Future<List<List<BibleContent>>> get bibleVolumeContents async {
    return await loadLocalDbBibleDataVolume(volumeSN);
  }

  /// 下一章
  nextChapter() async {
    chapterSN += 1;
  }

  /// 上一章
  preChapter() async {
    chapterSN -= 1;
  }

  @override
  dispose() {
    // db?.close();
    super.dispose();
  }

  Stream<bool> get playingStream => BiblePlayer.playingStream;
  Stream<Duration> get positionStream => BiblePlayer.positionStream;

  void play() async {
    await BiblePlayer.playBible(volumnSNFullName!, chapterSN.toString());
  }

  void copy() async {
    String text = '';
    final List<BibleContent>? contents = await bibleContents;
    if (contents != null) {
      for (int i = 0; i < verseNumbers.length; i++) {
        text +=
            '（$volumnSNFullName${chapterSN.toString()}：${verseNumbers[i]}）${contents[verseNumbers[i] - 1].Lection.trim()}';
      }
    }
    Clipboard.setData(ClipboardData(text: text));
    Toast.showToast('复制成功');
  }

  final BibleScrollViewController bibleController = BibleScrollViewController();

  void scrollToIndex(int index) async {
    await Future.delayed(const Duration(milliseconds: 100));
    bibleController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }

  /// 书签
  BookMarkUtil bookMarkUtil = BookMarkUtil();

  void addBookmark() {
    ZhangBibleDict zhangBibleDict = ZhangBibleDict(
        title: currentBibleDict!.FullName,
        shortTitle: currentBibleDict!.ShortName,
        enTitle: currentBibleDict!.PinYin,
        enShortTitle: currentBibleDict!.PinYin,
        total: currentBibleDict!.ChapterNumber,
        children: []);
    JieBibleDict jieBibleDict = JieBibleDict(
        title: currentChapter!.ChapterSN.toString(),
        total: currentChapter!.VerseNumber);
    bookMarkUtil
        .insert(zhangBibleDict, jieBibleDict, verseNumbers.first)
        .then((value) {
      Toast.showToast('添加成功');
    }).catchError((err) {
      Toast.showToast(err);
    });
  }

  void bookmark(BuildContext context) {
    //打开一个底部弹窗
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          //这里是modal的边框样式
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return BookMark(
            color: context.isDarkMode ? Colors.deepPurple : Colors.black,
            bookMarkUtil: bookMarkUtil,
            change: (ZhangBibleDict q, JieBibleDict z, int j) {
              final String shortTitle = q.shortTitle;
              final (cvolumnNs, character, verseSNs) = BibleModel.transform(
                  '$shortTitle${z.title}:$j',
                  dictList: dictList);
              volumeSN = cvolumnNs;
              chapterSN = character;
              verseNumbers = verseSNs;
              scrollToIndex(j - 1);
              Navigator.of(context).pop();
            },
          );
        });
  }

  /// 清空选择
  void clearSelect() {
    verseNumbers = [];
  }

  static Future<Database?> loadBibleDb() async {
    if (db != null) {
      return db;
    }
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // 获取服务器上的最新版本号
    BibleProvider provider = BibleProvider();
    String? serverVersion = await provider.getBibleVersion();

    // 获取本地存储的版本号
    GetStorage getStorage = GetStorage();
    String? localVersion = await getStorage.readString('bible_db_version');
    String path = join(documentsDirectory.path, '${localVersion}_bible.db');

    print('localVersion: $localVersion serverVersion: $serverVersion');
    // 检查数据库是否存在且版本是否需要更新
    if (localVersion == serverVersion && await File(path).exists()) {
      return await openReadOnlyDatabase(path);
    }

    // 如果数据库不存在或版本过旧或首次安装，下载新版本
    if (serverVersion != null) {
      // 构建新的文件路径，使用版本号作为前缀
      String newPath =
          join(documentsDirectory.path, '${serverVersion}_bible.db');

      var dio = Dio();
      try {
        // 下载新版本的数据库文件
        String downloadUrl =
            'https://oss.top237.top/npm/static/sqllite/${serverVersion}_bible.db';
        await dio.download(downloadUrl, newPath);

        // 删除旧的数据库文件（如果存在且不是同一个文件）
        if (await File(path).exists() && newPath != path) {
          await File(path).delete();
        }

        // 更新路径为新文件路径
        path = newPath;

        // 更新本地存储的版本号
        await getStorage.writeString('bible_db_version', serverVersion);

        db ??= await openReadOnlyDatabase(path);
        return db;
      } catch (e) {
        print('下载圣经数据库失败: $e');
        // 如果下载失败但本地文件存在，尝试使用本地文件
        if (await File(path).exists()) {
          return await openReadOnlyDatabase(path);
        }
        return null;
      }
    } else {
      // 如果无法获取服务器版本，使用默认的下载方式
      var dio = Dio();
      try {
        await dio.download(hobileBookDb, path);
        db ??= await openReadOnlyDatabase(path);
        return db;
      } catch (e) {
        return null;
      }
    }
  }

  /// 加载整卷
  static Future<List<BibleSearchContent>> search(
      String searchText, Database db) async {
    List<Map>? list = (await db.rawQuery(
            'select ID,VolumeSN,ChapterSN,VolumeSN,Lection,VerseSN, b.ShortName as ShortName from Bible a left join BibleID b on a.VolumeSN = b.SN where a.Lection like \'%$searchText%\';'))
        .cast<Map>();
    List<BibleSearchContent>? bibleContentList =
        list.map<BibleSearchContent>((item) {
      return BibleSearchContent(
          ID: item['ID'],
          VolumeSN: item['VolumeSN'],
          ChapterSN: item['ChapterSN'],
          VerseSN: item['VerseSN'],
          Lection: item['Lection'],
          ShortName: item['ShortName']);
    }).toList();

    return bibleContentList;
  }
}
