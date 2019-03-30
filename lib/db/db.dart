import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DbManager{
  DbManager._internal(); //dart中单例模式是这样写的

  static DbManager singleton = DbManager._internal();//single instance


  //获取路径
  Future<String> get dbPath async{
    var directory =  await getApplicationDocumentsDirectory();
    String path = directory.path + "WanAndroid.db";
    return path;
  }

//创建数据库

  Future<Database> get localFile async{
    final path = await dbPath;
    var db = openDatabase(path,version: 1,
          onCreate: (Database db,int version)async{
      await db.execute("CREATE TABLE history (id INTEGER PRIMARY KEY,name TEXT)");
          });
    return db;
  }
  //delete table
  Future<Null> clear() async{
    final db = await localFile;
    db.execute("delete from history");
  }
  //save data
  Future<int> save(String key)async{
    final db = await localFile;
    return db.transaction((trx){
      trx.rawInsert("INSERT INTO history(name) VALUES('${key}')");
    });
  }

  //compare data
  Future<bool> hasSameData(String key)async{
    final db = await localFile;
    List<Map> list = await db.rawQuery('SELECT * FROM history where name = "${key}"');
    return list.length != 0;
  }

  //fetch data
  Future<List<Map>> getHistory() async{
    final db = await localFile;
    List<Map> list = await db.rawQuery('SELECT * FROM history ORDER BY id DESC');
    return list;
  }

}
















