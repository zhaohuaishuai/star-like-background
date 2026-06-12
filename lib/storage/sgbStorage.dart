import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../type/sgbType.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
class SgbStorage {
  GetStorage storage = GetStorage();
  // 当前播放的播单id
  set activeIndex(index)=>storage.write('activeIndex', index);
  get activeIndex => storage.read('activeIndex');
  // 当前版本号存储
  get version =>storage.read("version");
  set version(version)=>storage.write("version", version);
  // 初始化播放的索引
  get playInitialIndex=>storage.read("playInitialIndex");
  set playInitialIndex(index)=>storage.write("playInitialIndex", index);
  // 历史播放记录
  set history(id){
    const history = 'history';
    set(history,id);
  }
  get history {
    return get('history');
  }

  set searchHistory(id){

    const history = 'searchHistory';
    set(history,id);


  }

  get searchHistory {
    var  history = "searchHistory";
    return get(history);
  }

  delSeacrchHistory(String id){
    del('searchHistory',id);
  }



  get(String key){
    var  history = key;
    var list = storage.read(history)??[];
    List<History> hlist = list.map((item){
      if(item is History){
        return item;
      }
      return History.fromJson(item);
    }).toList().cast<History>().toList();
    hlist
        .sort((History a, History b){
      var at = DateTime.parse(a.createDate as String).microsecondsSinceEpoch;
      var bt = DateTime.parse(b.createDate as String).microsecondsSinceEpoch;
      return bt - at;
    });
    List<SgbData> sgbAllList = Get.find<SgbContainer>().sgb.value;

    if(sgbAllList.length==0){
      return [];
    }
    var l = hlist.map((hi){
      return sgbAllList.firstWhere((item){
        return item.id == hi.id;
      });
    }).toList();

    return l;

  }

  del(String key,String id){
    var list = storage.read(key)??[];
    if(list.length == 0)return;
    int findHistoryIndex = list.indexWhere((item){
      if(item is History){
        return item.id == id;
      }
      return item['id'] == id;
    });
    if(findHistoryIndex != -1) {
      list.removeAt(findHistoryIndex);
      storage.write(key, list);
    }
  }

  set(String key,String id){
    var history = key;
    var list = storage.read(history)??[];
    list = list.map((item){
      if(item is History){
        return item;
      }
      return History.fromJson(item);
    }).toList().cast<History>();
    int findHistoryIndex = list.indexWhere((item){
      if(item is History){
        return item.id == id;
      }
      return item['id'] == id;
    });
    if(findHistoryIndex != -1){

      var findHistory = list[findHistoryIndex];
      list.removeAt(findHistoryIndex);
      if(findHistory is History){
        if(findHistory.playCount == null){
          findHistory.playCount = 2;
        } else {
          int sum = findHistory.playCount!.toInt() + 1;
          findHistory.playCount = sum ;
        }

        findHistory.createDate = DateTime.now().toString();

      } else {

        if(findHistory['playCount'] == null){
          findHistory['playCount'] = 2;
        } else {
          int sum = findHistory['playCount']!.toInt() + 1;
          findHistory['playCount'] = sum ;
        }
        findHistory['createDate'] = DateTime.now().toString();
      }
      list.add(findHistory);
      storage.write(history,list);
      return;
    }
    if(list.length>10){
      list.removeAt(0);
    }
    History historyModel = History(id:id,createDate: DateTime.now().toString(),playCount: 1);
    list.add(historyModel);
    storage.write(history, list);

  }

  String songlistkey = 'me_songlist';
  addSongList(SongListData data){
    var list = storage.read(songlistkey);
    if(list == null){
      list = [];
    }
    list = list.map((item){
      if(item is SongListData){
        return item;
      }
      return SongListData.fromJson(item);
    }).toList().cast<SongListData>();
    var index = list.indexWhere((el){
      return el.id == data.id;
    });
    if(index !=-1){
      list.removeAt(index);
      print("更新插入数据");
      list.insert(index,data);
    }else {
      list.add(data);
    }
    storage.write(songlistkey,list);
  }
  delSongList(String id){
    var list = storage.read(songlistkey);
    list = list.map((item){
      if(item is SongListData){
        return item;
      }
      return SongListData.fromJson(item);
    }).toList().cast<SongListData>();
    var index = list.indexWhere((el){
      return el.id == id;
    });
    if(index!=-1){
      list.removeAt(index);
    }

    storage.write(songlistkey,list);
  }
  SongListData getSongData(String id) {
    var list = storage.read(songlistkey);
    list = list.map((item){
      if(item is SongListData){
        return item;
      }
      return SongListData.fromJson(item);
    }).toList().cast<SongListData>();
    return list.firstWhere((el){
      return el.id == id;
    });
  }
  List<SongListData> get songList {
    var list = storage.read(songlistkey);
    if(list == null){
      List<SongListData> list = [];
      return list;
    }
    list = list.map((item){
      if(item is SongListData){
        return item;
      }
      return SongListData.fromJson(item);
    }).toList().cast<SongListData>();
    list.sort((SongListData a,SongListData b){
      var at = DateTime.parse(a.createdAt as String).microsecondsSinceEpoch;
      var bt = DateTime.parse(b.createdAt as String).microsecondsSinceEpoch;
      return bt - at;
    });
    return list;
  }


  set loopMode(LoopMode loopMode){
    int tmp = 0;
    switch(loopMode){
      case LoopMode.off:
        tmp=0;
        break;
      case LoopMode.one:
        tmp=1;
        break;
      case LoopMode.all:
        tmp = 2;
        break;
    }
    storage.write("loopModel",tmp);
  }
  LoopMode get loopMode{
    int tmp = storage.read("loopModel");
    print("tmp-->${tmp}");
    LoopMode loopMode = LoopMode.all;
    if(tmp == 0){
      loopMode = LoopMode.off;
    }else if(tmp == 1){
      loopMode = LoopMode.one;
    }else if(tmp == 2){
      loopMode = LoopMode.all;
    }else if (tmp ==null){
      loopMode = LoopMode.off;
    }
    return loopMode;
  }

  set touPingCode(code)=>storage.write("topPingCode",code);

  get touPingCode {
    dynamic touPingCode = storage.read("topPingCode");
    if(touPingCode == null){
      Random random = new Random();
      touPingCode = random.nextInt(9000) + 1000;
      storage.write("topPingCode",touPingCode);
    }
    return touPingCode;
  }


  //删除诗歌本相关的缓存
  removeSgbAll() async {
    await storage.remove("sgbAllList");
    await storage.remove("/start/shijidb/list?pageNum=1&pageSize=10000&isUpper=1");
  }

}