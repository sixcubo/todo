import 'package:flutter/material.dart';
import 'package:todo/database/db_provider.dart';
import 'package:todo/model/task_list.dart';

///此类为单例模式
// ///全局唯一变量[tasklistTable]
// TasklistTable tasklistTable = TasklistTable();

class TasklistTable extends ChangeNotifier {
  static TasklistTable _singleton = new TasklistTable._internal();

  TasklistTable._internal();

  factory TasklistTable() => _singleton;

  List<Tasklist> _data;

  init() async {
    //debugPrint("初始化ListTable");
    this._data = await queryTasklistTable();
  }

  get data => _data;

  Tasklist getTasklist(int id) {
    for (var i in _data) {
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

    //debugPrint('查询列表$id : ${res.toString()}');

    return Tasklist.fromMap(res[0]);
  }

  insertTasklist(Tasklist list) async {
    var db = await dbProvider.db;
    var sql = """
    INSERT INTO "ListTable" (listID, listName, color, count, doneCount)
    VALUES(NULL, ?, ?, ?, ?)
    """;
    await db.rawInsert(sql, [
      list.tasklistName,
      list.color,
      list.count,
      list.doneCount,
    ]);

    await update();
  }

  updateName(int id, String name) async {
    var db = await dbProvider.db;
    var sql = """
    UPDATE "ListTable"
    SET listName=?
    WHERE listID=?
    """;
    await db.rawUpdate(sql, [name, id]);

    await update();
  }

  updateColor(int id, int color) async {
    var db = await dbProvider.db;
    var sql = """
    UPDATE "ListTable"
    SET color=?
    WHERE listID=?
    """;
    await db.rawUpdate(sql, [color, id]);

    await update();
  }

  deleteTasklist(int id) async {
    var db = await dbProvider.db;
    var sql = """
    DELETE FROM "ListTable"
    WHERE listID=?
    """;
    var sql2 = """
    DELETE FROM "ListTable"
    WHERE listID=?
    """;

    await db.transaction(
      (txn) async {
        await txn.rawDelete(sql, [id]);
        await txn.rawDelete(sql2, [id]);
      },
    );

    await update();
  }

  update() async {
    debugPrint('tasklist Table通知');
    await init();
    notifyListeners();
  }
}
