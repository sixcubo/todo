import 'package:flutter/material.dart';
import 'package:todo/database/db_provider.dart';
import 'package:todo/model/task_list.dart';

///此类为单例模式
///全局唯一变量[tasklistTable]
TasklistTable tasklistTable = TasklistTable();

class TasklistTable extends ChangeNotifier {
  static TasklistTable _singleton = new TasklistTable._internal();

  TasklistTable._internal();

  factory TasklistTable() => _singleton;

  List<Tasklist> data;

  init() async {
    debugPrint("初始化ListTable");
    this.data = await queryTasklistTable();
  }

  Tasklist getTasklist(int id) {
    for (var i in data) {
      if (id == i.tasklistID) {
        return i;
      }
    }

    return null;
  }

  static Future<List<Tasklist>> queryTasklistTable() async {
    var db = await dbProvider.db;

    var sql = """
    SELECT * FROM "listTable"
    """;
    var res = await db.rawQuery(sql);

    return res.map((e) => Tasklist.fromMap(e)).toList();
  }

  static Future<Tasklist> queryTasklistExactID(int id) async {
    var db = await dbProvider.db;

    var sql = """
    SELECT * FROM "listTable"
    WHERE listID=?
    """;
    var res = await db.rawQuery(sql, [id]);

    return Tasklist.fromMap(res[0]);
  }

  Future<int> insertTasklist(Tasklist list) async {
    var db = await dbProvider.db;

    var sql = """
    INSERT INTO "ListTable" (listID, listName, color, count, doneCount)
    VALUES(NULL, ?, ?, ?, ?)
    """;
    var res = await db.rawInsert(sql, [
      list.tasklistName,
      list.color,
      list.count,
      list.doneCount,
    ]);

    init();
    notifyListeners();

    return res;
  }

  deleteTasklist(Tasklist list) async {
    var db = await dbProvider.db;

    var sql = """
    DELETE FROM "listTable"
    WHERE listID=?
    """;
    db.rawDelete(sql, [list.tasklistID]);

    init();
    notifyListeners();
  }

  whenUpdate() {
    init();
    notifyListeners();
  }
}
