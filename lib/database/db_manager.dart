import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

class DBManager {
  static DBManager _dbManager = new DBManager();

  static Database _database;
  static const _VERSION = 1;
  static const _NAME = "todo.db";

  static Future<DBManager> getInstance() async {
    if (_database == null) {
      await initDB();
    }
    return _dbManager;
  }

  static initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _NAME);

    var createListTableSql = """
    CREATE TABLE "listTable" (
    "listID" integer PRIMARY KEY AUTOINCREMENT,
    "listName" TEXT NOT NULL,
    "color" TEXT NOT NULL,
    "count" INTEGER,
    "doneCount" integer
    )
    """;

    var createTaskTableSql = """
    CREATE TABLE "TaskTable" (
    "taskID" INTEGER PRIMARY KEY AUTOINCREMENT,
    "taskName" TEXT,
    "state" integer,
    "dateTime" TEXT,
    "listID" integer,
    CONSTRAINT "taskOfList" FOREIGN KEY ("listID") REFERENCES "listTable" ("listID")
    );
    """;

    _database = await openDatabase(
      path,
      version: _VERSION,
      onCreate: (Database db, int version) async {
        debugPrint('createListTableSql, createTaskTableSql');
        await db.execute(createListTableSql);
        await db.execute(createTaskTableSql);
      },
    );
  }

  addTaskList(TaskList list) {
    debugPrint('add list');
    debugPrint(list.toString());
  }

  deleteTaskList(TaskList list) {
    debugPrint('delete list');
  }

  addTaskElem(String listName, Task elem) {
    debugPrint('add elem to list');
  }

  deleteTaskElem(String listName, Task elem) {
    debugPrint('delete elem to list');
  }
}
