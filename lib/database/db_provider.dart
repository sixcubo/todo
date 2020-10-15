import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

///此类为单例模式
///定义全局变量[dbProvider], 引入此文件即可使用.
DBProvider dbProvider = DBProvider();

class DBProvider {
  static DBProvider _singleton = new DBProvider._internal();
  DBProvider._internal();
  factory DBProvider() => _singleton;

  static const _VERSION = 1;
  static const _NAME = "todo.db";
  static Database _database;

  Future<Database> get db async {
    if (_database == null) {
      await initDB();
    }
    return _database;
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

    debugPrint('初始化数据库');
  }

  // Future<Map<int, List<Task>>> queryTaskTable() async {
  //   if (_database == null) {
  //     await initDB();
  //   }
  //
  //   List<TaskList> listTable = await queryListTable();
  //   Map<int, List<Task>> res = Map();
  //
  //   if (listTable.isNotEmpty) {
  //     for (var list in listTable) {
  //       List<Task> tasks = await queryTasksExactList(list.listID);
  //       res[list.listID] = tasks;
  //     }
  //   }
  //   return res;
  // }

  // Future<TaskList> queryTaskListExactID(int id) async {
  //   if (_database == null) {
  //     await initDB();
  //   }
  //
  //   var sql = """
  //   SELECT * FROM "listTable"
  //   WHERE listID=?
  //   """;
  //
  //   var res = await _database.rawQuery(sql, [id]);
  //   //debugPrint(res.toString());
  //
  //   return TaskList.fromMap(res[0]);
  // }

  // Future<List<TaskList>> queryListTable() async {
  //   if (_database == null) {
  //     await initDB();
  //   }
  //
  //   var sql = """
  //   SELECT * FROM "listTable"
  //   """;
  //   var res = await _database.rawQuery(sql);
  //
  //   return res.map((e) => TaskList.fromMap(e)).toList();
  // }

  // Future<int> insertTaskList(TaskList list) async {
  //   var sql = """
  //   INSERT INTO "ListTable" (listID, listName, color, count, doneCount)
  //   VALUES(NULL, ?, ?, ?, ?)
  //   """;
  //
  //   var res = await _database.rawInsert(sql, [
  //     list.listName,
  //     list.color,
  //     list.count,
  //     list.doneCount,
  //   ]);
  //
  //   queryListTable();
  //
  //   return res;
  // }

  // deleteTaskList(TaskList list) {
  //   var sql = """
  //   DELETE FROM "listTable"
  //   WHERE listID=?
  //   """;
  //
  //   _database.rawDelete(sql, [list.listID]);
  // }

  // Future<List<Task>> queryTasksExactList(int listID) async {
  //   var sql = """
  //   SELECT * FROM "taskTable"
  //   WHERE "taskTable".listID = $listID
  //   """;
  //
  //   List<Map<String, dynamic>> res = await _database.rawQuery(sql);
  //
  //   return res.map((e) => Task.fromMap(e)).toList();
  // }

  // // 在TaskTable插入一条记录, 同时更新TaskList
  // insertTask(TaskList list, Task task) async {
  //   var sql1 = """
  //   INSERT INTO "taskTable" (taskID, taskName, state, dateTime, listID)
  //   VALUES(NULL, ?, ?, NULL, ?)
  //   """;
  //   var sql2 = """
  //   UPDATE "listTable"
  //   SET count=?
  //   WHERE listID=?
  //   """;
  //
  //   await _database.transaction(
  //         (txn) async {
  //       await txn.rawInsert(sql1, [
  //         task.taskName,
  //         task.state,
  //         task.listID,
  //       ]);
  //
  //       await txn.rawUpdate(sql2, [
  //         list.count + 1,
  //         list.listID,
  //       ]);
  //
  //       //debugPrint('插入同时更新count');
  //     },
  //   );
  // }
  //
  // updateState(Task task) async {
  //   int doneCount = (await queryTaskListExactID(task.listID)).doneCount;
  //
  //   var sql1 = """
  //   UPDATE "taskTable"
  //   SET state=?
  //   WHERE listID=? AND taskID=?
  //   """;
  //
  //   var sql2 = """
  //   UPDATE "listTable"
  //   SET doneCount=?
  //   WHERE listID=?
  //   """;
  //
  //   await _database.transaction((txn) async {
  //     await txn.rawUpdate(sql1, [
  //       task.state == 1 ? 0 : 1,
  //       task.listID,
  //       task.taskID,
  //     ]);
  //
  //     await txn.rawUpdate(sql2, [
  //       task.state == 1 ? (doneCount - 1) : (doneCount + 1),
  //       task.listID,
  //     ]);
  //   });
  // }
  //
  // deleteTask(Task task) async {
  //   debugPrint('删除任务');
  //
  //   TaskList list = await queryTaskListExactID(task.listID);
  //
  //   var sql1 = """
  //   DELETE FROM "taskTable"
  //   WHERE taskID=?
  //   """;
  //
  //   var sql2 = """
  //   UPDATE "listTable"
  //   SET doneCount=?, count=?
  //   WHERE listID=?
  //   """;
  //
  //   await _database.transaction((txn) async {
  //     await txn.rawDelete(sql1, [task.taskID]);
  //
  //     await txn.rawUpdate(sql2, [
  //       task.state == 1 ? (list.doneCount - 1) : (list.doneCount),
  //       list.count - 1,
  //       task.listID,
  //     ]);
  //   });
  // }
}
