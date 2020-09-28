import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

class DBManager {
  static const _VERSION = 1;
  static const _NAME = "todo.db";

  static DBManager _dbManager = new DBManager();
  static Database _database;

  static Future<DBManager> getInstance() async {
    if (_database == null) {
      await initDB();
    }
    return _dbManager;
  }

  // 初始化[_database]
  static initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _NAME);

    var createListTableSql = """
    CREATE TABLE "listTable" (
    "listID" integer PRIMARY KEY AUTOINCREMENT,
    "listName" TEXT NOT NULL,
    "color" integer NOT NULL,
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

  Future<List<TaskList>> queryTaskList() async {
    debugPrint('query list');

    var sql = """
    SELECT * FROM "listTable"
    """;

    var res = await _database.rawQuery(sql);
    debugPrint(res.toString());

    return res.map((e) => TaskList.fromMap(e)).toList();
  }

  Future<int> insertTaskList(TaskList list) async {
    debugPrint('add list');
    //debugPrint(list.toString());
    //debugPrint(list.color.toString());

    //_database.rawDelete('DELETE FROM "listTable"');

    var sql = """
    INSERT INTO "ListTable" (listID, listName, color, count, doneCount)
    VALUES(NULL, ?, ?, ?, ?)
    """;

    var res = await _database.rawInsert(sql, [
      list.listName,
      list.color,
      list.count,
      list.doneCount,
    ]);

    queryTaskList();

    return res;
  }

  // deleteTaskList(TaskList list) {
  //   debugPrint('delete list');

  //   var sql = """
  //   DELETE FROM "taskTable"
  //   """;

  //   _database.rawDelete('DELETE FROM "taskTable"');
  // }

  Future<Map<int, List<Task>>> queryAll() async {
    Map<int, List<Task>> res = Map();

    List<TaskList> listTable = await queryTaskList();

    if (listTable.isNotEmpty) {
      for (var list in listTable) {
        List<Task> tasks = await queryTasksInExactList(list.listID);
        //if (tasks.isEmpty) {}
        res[list.listID] = tasks;
      }
    }
    return res;
  }

  Future<List<Task>> queryTasksInExactList(int listID) async {
    var sql = """
    SELECT * FROM "taskTable" 
    WHERE "taskTable".listID = $listID
    """;

    List<Map<String, dynamic>> res = await _database.rawQuery(sql);

    debugPrint('指定查找结果: ' + res.toString());

    return res.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> insertTask(TaskList list, Task task) async {
    debugPrint('add task to list');

    var sql = """
    INSERT INTO "taskTable" (taskID, taskName, state, dateTime, listID)
    VALUES(NULL, ?, ?, NULL, ?)
    """;

    return await _database.rawInsert(sql, [
      task.taskName,
      task.state,
      task.listID,
    ]);
  }

  // deleteTask(String listName, Task task) {
  //   debugPrint('delete elem to list');
  // }
}
