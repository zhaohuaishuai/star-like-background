import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/bible.dart';
import 'package:m/data/api/sgb.dart';

import 'package:m/data/module/shiji_type.dart';
import 'package:m/data/module/song.dart';
import 'package:m/data/module/user_song.dart';
import 'package:m/data/module/user_song_detail.dart';
import 'package:m/data/services/sgb.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/features/pages/bible/module/bible_dict.dart';
import 'package:m/features/pages/bible/module/bible_search_content.dart';
import 'package:m/features/pages/bible/module/chapter.dart';
import 'package:sqflite/sqflite.dart';

class SearchPageController extends GetxController {
  GetStorage box = GetStorage();
  SgbProvider api = Get.put<SgbProvider>(SgbProvider());
  BibleProvider bibleApi = BibleProvider();

  final Rx<UserSong?> _searchHistory = Rx<UserSong?>(null);
  TextEditingController searchTextController = TextEditingController();
  final Rx<String> _searchText = Rx<String>('');
  String get searchText => _searchText.value;
  List<UserSongDetail?> get hostoryList {
    if (_searchHistory.value == null) return [];
    String? list = _searchHistory.value?.list;
    return SgbService.to.getUserSongDetailList(list);
  }

  List<UserSongDetail> get searchTitleList {
    return SgbService.to.searchTitle(searchText).map((e) {
      ShijiType? shijiType = SgbService.to.getShiJiTypeById(e.shijiIndex);
      return UserSongDetail(
        id: e.id,
        mulu: "${e.xuhao.toString().padLeft(3, '0')}.${e.title}",
        type: GeDanListType.geDan,
        shijiName: shijiType?.name ?? '',
        ShijiTypeId: e.shijiIndex,
      );
    }).toList();
  }

  final Rx<List<Song>> _searchLyricList = Rx<List<Song>>([]);
  List<Song> get searchLyricList => _searchLyricList.value;
  setSearchLyricList(String searchText) async {
    if(searchText.isEmpty || searchText.length < 2) {
      _searchLyricList.value = [];
      return;
    }
    _searchLyricList.value = await api.searchByLryic(searchText);
  }



  Database? db;
  List<BibleDict> dictList = [];
  Future<void>  getBibleDictList() async {
    if(dictList.isNotEmpty) {
      return;
    }
     dictList = await bibleApi.getBibleDictList(); 
  }


  final RegExp reg1 = RegExp(r'^([\u4e00-\u9fa5]+)(\d+):{0,1}$');
  final RegExp reg2 = RegExp(r'^([\u4e00-\u9fa5]+)(\d+):(\d+)$');
  final RegExp reg3 = RegExp(r'^([\u4e00-\u9fa5]+)(\d+):(\d+)-(\d+){0,1}$');

  (BibleDict?,Chapter?) _getBibleDictAndChapter(String volumeSNName,String chapter) {
    BibleDict? volumeSNDict = dictList.firstWhereOrNull((element) {
      if(volumeSNName.isEmpty) {
        return false;
      }
      if(volumeSNName.length > 2) {
        return element.searchNames.sublist(0,1).any((name) => name.contains(volumeSNName));
      }
      // 只取缩写部分。
      return  element.searchNames.sublist(2).any((name) => name.contains(volumeSNName));
    });
    Chapter? chapterDict = volumeSNDict?.children.firstWhereOrNull((element) => element.ChapterSN == int.parse(chapter)); 
    return (volumeSNDict,chapterDict);
  }
  /// 经文目录搜索过滤自动提示
   List<String>? get bibleDictList {  
     List<String> verseList = [];
    // 按章节全搜索
    if (reg1.hasMatch(searchText)) { 
      final match = reg1.firstMatch(searchText);
      String volumeSNName = match?.group(1) ?? '';
      String chapter = match?.group(2) ?? ''; 
       
      final (volumeSNDict,chapterDict) = _getBibleDictAndChapter(volumeSNName,chapter);
      
      if(volumeSNDict == null || chapterDict == null) {
        return null;
      } 
     
      verseList.add(searchText);
      for(int i = 0; i < chapterDict.VerseNumber; i++) {
       
        verseList.add('${volumeSNDict.ShortName}${chapterDict.ChapterSN}:${i+1}');
      }
   
    }

  
    // 按章和节搜索
    if (reg2.hasMatch(searchText)) {
        final match = reg2.firstMatch(searchText);
        String volumeSNName = match?.group(1) ?? '';
        String chapter = match?.group(2) ?? ''; 
        String verse = match?.group(3) ?? '';
        final (volumeSNDict,chapterDict) = _getBibleDictAndChapter(volumeSNName,chapter);
        if(volumeSNDict == null || chapterDict == null) {
          return null;
        }
        if( int.parse(verse) <= chapterDict.VerseNumber && int.parse(verse) > 0 )
        {
          verseList.add(searchText);
        }  
    }

   
     // 按章节范围搜索
    if (reg3.hasMatch(searchText)) {
      debugPrint('reg3 match : ${reg3.hasMatch(searchText)}');
      final match = reg3.firstMatch(searchText);
      String volumeSNName = match?.group(1) ?? '';
      String chapter = match?.group(2) ?? ''; 
      String verse = match?.group(3) ?? '';
      String? verseEnd = match?.group(4);
      final (volumeSNDict,chapterDict) = _getBibleDictAndChapter(volumeSNName,chapter);
      if(volumeSNDict == null || chapterDict == null) {
        return null;
      }

       if( verseEnd == null )
      {
        for(int i = int.parse(verse) ; i <=  chapterDict.VerseNumber; i++) {
          verseList.add('${volumeSNDict.ShortName}${chapterDict.ChapterSN}:$verse-${i+1}');
        }
      }

      if( verseEnd != null && int.parse(verse) < int.parse(verseEnd)  && int.parse(verseEnd) <= chapterDict.VerseNumber){ 
        verseList.add(searchText);  

          
      }  
    }


  
    return verseList;  
  }
  
  /// 经文搜索
  final Rx<List<BibleSearchContent>> _searchVerseList = Rx([]);
  List<BibleSearchContent> get searchVerseList => _searchVerseList.value;
 
   setSearchVerseList(String searchText) async {
    if(db == null || searchText.length < 2) {
      return [];
    }
    _searchVerseList.value = await BibleModel.search(searchText,db!); 
  }

 

  @override
  void onInit() {
    super.onInit();
    init();
  }

  // ignore: unused_element
  _mokeData() {
    _searchHistory.value = UserSong(
      id: 1,
      name: 'search history',
      userId: 1,
      createTime: '2022-05-18 16:00:00',
      updateTime: '2022-05-18 16:00:00',
      list:
          'facb8c3a55b4ace2db65da6b8145793e|0,0d67e8b9a4ee531babda2a91691b4484|0,|0,27ab051e3b277dfa1673d83a687109e9|0,d9a8133a082d653c08e446a88e328edf|0,5b00f970605d87b30340f37f7f46df01|0,5b00f970605d87b30340f5c44f8609ba|0,5b00f970605d87b30340f5eb551d24a5|0,66d376c6912f0fc5247a21c9d56dce9a|0,撒上7:1-14|1,2f4df9158f89b3a7c0d7e4bcf65943a0|0,诗23:1-6|1,5b00f970605d87b30340f60f06c918b4|0',
    );
  }

  init() async {
    // _mokeData();
    String? history = await box.readString(GetStorage.searchHistory);
    debugPrint('history: $history');
    if (history != null) {
      // box.remove(GetStorage.searchHistory);
      try {
        _searchHistory.value = UserSong.fromJson(jsonDecode(history));
      } catch (e) {
        box.remove(GetStorage.searchHistory);
      }
    }
    searchTextController.addListener(() {
      _searchText.value = searchTextController.text;
      setSearchLyricList(searchTextController.text);
      setSearchVerseList(searchTextController.text);

    });

    _searchHistory.listen((value) async {
      if (value != null) {
        await box.writeString(
            GetStorage.searchHistory, jsonEncode(value.toJson()));
      } else {
        delHistory();
      }
    }); 



    getBibleDictList(); 
    db ??= await BibleModel.loadBibleDb();
    
 
  }

  toPlayer(String id, int typeId) async {

    if(typeId == -1){
      toBible(id);
      return;
    }
    RouterUtils.toPlayer(id, typeId, toPathCallback: (path) {
      // Get.offAllNamed(path);
      Get.offNamedUntil(path, (route) {
        return route.settings.name == AppRoutes.index;
      });
    });

    String jid = '$id|0';
    setSearchHistory(jid);
  }

  void setSearchHistory(String jid) {
    if (_searchHistory.value == null) {
      _searchHistory.value = UserSong(
        createTime: Utils.simplyFormat(time: DateTime.now()),
        updateTime: Utils.simplyFormat(time: DateTime.now()),
        userId: -1,
        list: jid,
        id: -1,
        name: '搜索历史',
      );
    } else {
      String list = '';
      
      if(_searchHistory.value?.list?.contains(jid) ?? false){
        return;
      }
      if(_searchHistory.value?.list !=null && _searchHistory.value!.list!.isNotEmpty){
         if (!_searchHistory.value!.list!.contains(jid)) {
        list = '${_searchHistory.value!.list},$jid';
      } else {
        list = _searchHistory.value!.list!.replaceAll(jid, '');
        list = '$jid,$list';
      }
      _searchHistory.value = _searchHistory.value!.copyWith(
        updateTime: Utils.simplyFormat(time: DateTime.now()),
        list: list,
      );
      }
     
    }
  }

  toBible(String id) {
    Get.toNamed(AppRoutes.jingwengres,arguments: {
      'id':id,
    });
     setSearchHistory('$id|1');
  }

  delHistory([String? id]) {
    if (id == null) {
      _searchHistory.value = null;
    } else {
      String list = _searchHistory.value!.list!.replaceAll('$id|0', '');
      list = list.replaceAll('$id|1', '');
      _searchHistory.value = _searchHistory.value!.copyWith(
        list: list,
        updateTime: Utils.simplyFormat(time: DateTime.now()),
      );
    }
  }

  @override
  void onClose() {
    searchTextController.dispose(); 
    super.onClose();
  }
}
