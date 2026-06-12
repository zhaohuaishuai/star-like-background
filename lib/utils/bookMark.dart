
import 'dart:convert';
import 'package:Shine_like_a_star/widget/BibleDict.dart';
import 'package:sqflite/sqflite.dart';
 
class BookMarkUtil {
  late Database db ;
  final String columnId = '_id';
  final String columnTitle = 'title';
  final String createDate = 'create_date';
  final String tableName = 'bookMark';
  final String columnZDict = 'z_dict';
  final String columnJDict = 'j_dict';
  final String columnIndex = 'j';
  BookMarkUtil(){
    // deleteDatabase("bookmark.db").then((value)  {
    //
    // });
    openDatabase("bookmark.db").then((value)  {
      db = value;
      this.createTable();
    });

  }

  createTable() async {
    bool isExists = await checkTableExists(db,tableName);
    if(!isExists){
      try{
        await db.execute('''
      create table $tableName ( 
        $columnId integer primary key autoincrement, 
        $columnTitle text not null,
        $createDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        $columnZDict text not null,
        $columnJDict text not null,
        $columnIndex text not null
        )
      ''');
      }catch(err){
        print(err.toString());
      }
    }

  }

  Future<int> insert(
      ZhangBibleDict zhangBibleDict,
      JieBibleDict jieBibleDict,
      int z,
      ) async {
    print("db.path->" + db.path);
    String title = "${zhangBibleDict!.title}${jieBibleDict.title}:${z}";
    List<Map> queryList = await db.query(tableName,where: '$columnTitle = ?',whereArgs: [title]);
    print("查询出来的数量" + queryList.length.toString());
    if(queryList.length > 0){
      throw "已经有这个书签了";
    }
    String sql = '''
    INSERT INTO $tableName ($columnTitle,$columnZDict,$columnJDict,$columnIndex) 
    values 
    ('$title','${json.encode(zhangBibleDict.toJson())}','${json.encode(jieBibleDict.toJson())}','$z');''';

    try{
      db.execute(sql);
      return 1;
    }catch(err){
      throw "增加书签失败";
    }
  }
  
  Future<bool> delete(id)async {
    try{
      int a = await  db.delete(tableName,where: '$columnId = ?',whereArgs: [id]);
      return a > 0;
    }catch(err){
      throw err;
    }

    
  }


  Future<List<Map>> queryList(){
    return db.query(tableName);
  }

  Future<bool> checkTableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
        [tableName]
    );
    return result.isNotEmpty;
  }
  
  
  

}