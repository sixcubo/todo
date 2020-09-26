import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:todo/model/task_elem.dart';

class DBManager {
  static Database _database;
  static const _VERSION = 1;
  static const _NAME = "todo.db";

  Future<Database> get database async {
    if (_database == null) {
      await initDB();
    }
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _NAME);

    var sql = """
    CREATE TABLE ListTable (
      ListName TEXT,
      Color TEXT,
      Count INTEGER,
      DoneCount INTEGER
    )
    """;

    _database = await openDatabase(
      path,
      version: _VERSION,
      onCreate: (Database db, int version) async {
        await db.execute(sql);
      },
    );
  }

  addToList(String listName, TaskElem elem) {

  }

}
