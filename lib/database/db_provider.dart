import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
}
