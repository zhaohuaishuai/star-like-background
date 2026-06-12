 
import 'dart:convert';

import 'package:flutter/material.dart';

import 'bible_dict.dart';
import 'package:sqflite/sqflite.dart';
class BookMarkUtil {
  late Database db ;
  final String _columnId = '_id';
  final String _columnTitle = 'title';
  final String _createDate = 'create_date';
  final String _tableName = 'bookMark';
  final String columnZDict = 'z_dict';
  final String columnJDict = 'j_dict';
  final String columnIndex = 'j';
  BookMarkUtil(){
    // deleteDatabase("bookmark.db").then((value)  {
    //
    // });
    openDatabase('bookmark.db').then((value)  {
      db = value;
      _createTable();
    });

  }

  _createTable() async {
    bool isExists = await checkTableExists(db,_tableName);
    if(!isExists){
      try{
        await db.execute('''
                        create table $_tableName ( 
                          $_columnId integer primary key autoincrement, 
                          $_columnTitle text not null,
                          $_createDate DATETIME DEFAULT CURRENT_TIMESTAMP,
                          $columnZDict text not null,
                          $columnJDict text not null,
                          $columnIndex text not null
                          )
      ''');
      }catch(err){
        debugPrint(err.toString());
      }
    }

  }

  Future<int> insert(
      ZhangBibleDict zhangBibleDict,
      JieBibleDict jieBibleDict,
      int z,
      ) async {
    debugPrint('db.path->${db.path}');
    String title = '${zhangBibleDict.title}${jieBibleDict.title}:$z';
    List<Map> queryList = await db.query(_tableName,where: '$_columnTitle = ?',whereArgs: [title]);
    debugPrint('查询出来的数量${queryList.length}');
    if(queryList.isNotEmpty){
      throw '已经有这个书签了';
    }
    String sql = '''
    INSERT INTO $_tableName ($_columnTitle,$columnZDict,$columnJDict,$columnIndex) 
    values 
    ('$title','${json.encode(zhangBibleDict.toJson())}','${json.encode(jieBibleDict.toJson())}','$z');''';

    try{
      await db.execute(sql);
      
      return 1;
    }catch(err){
      throw '增加书签失败';
    }
  }
  
  Future<bool> delete(id)async {
    try{
      int a = await  db.delete(_tableName,where: '$_columnId = ?',whereArgs: [id]);
      return a > 0;
    }catch(err){
      rethrow;
    }

    
  }


  Future<List<Map>> queryList(){
    return db.query(_tableName);
  }

  Future<bool> checkTableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
        [tableName]
    );
    return result.isNotEmpty;
  } 
  

}