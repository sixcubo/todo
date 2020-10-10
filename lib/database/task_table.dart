import 'package:flutter/material.dart';
import 'package:todo/database/db_provider.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

TaskTable taskTable = TaskTable();

class TaskTable extends ChangeNotifier {
  static TaskTable _singleton = TaskTable._internal();
  TaskTable._internal();
  factory TaskTable() => _singleton;

  Map<int, List<Task>> data;

  init() async {
    debugPrint('初始化TaskTable');
    data = await queryTaskTable();
  }

  static Future<Map<int, List<Task>>> queryTaskTable() async {
    List<Tasklist> listTable = await TasklistTable.queryTasklistTable();
    Map<int, List<Task>> res = {};

    if (listTable.isNotEmpty) {
      for (var list in listTable) {
        List<Task> tasks = await queryTasksExactListID(list.tasklistID);
        res[list.tasklistID] = tasks;
      }
    }
    return res;
  }

  static Future<List<Task>> queryTasksExactListID(int listID) async {
    var db = await dbProvider.db;

    var sql = """
    SELECT * FROM "taskTable"
    WHERE "taskTable".listID = $listID
    """;
    List<Map<String, dynamic>> res = await db.rawQuery(sql);

    return res.map((e) => Task.fromMap(e)).toList();
  }

  insertTask(Task task) async {
    Tasklist list = await TasklistTable.queryTasklistExactID(task.listID);

    var db = await dbProvider.db;
    var sql1 = """
    INSERT INTO "taskTable" (taskID, taskName, state, dateTime, listID)
    VALUES(NULL, ?, ?, NULL, ?)
    """;
    var sql2 = """
    UPDATE "listTable"
    SET count=?
    WHERE listID=?
    """;

    await db.transaction(
      (txn) async {
        await txn.rawInsert(sql1, [
          task.taskName,
          task.state,
          task.listID,
        ]);
        await txn.rawUpdate(sql2, [
          list.count + 1,
          list.tasklistID,
        ]);
      },
    );

    init();
    notifyListeners();
    tasklistTable.whenUpdate();
  }

  updateState(Task task) async {
    int doneCount = (await TasklistTable.queryTasklistExactID(task.listID)).doneCount;

    var db = await dbProvider.db;
    var sql1 = """
    UPDATE "taskTable"
    SET state=?
    WHERE listID=? AND taskID=?
    """;
    var sql2 = """
    UPDATE "listTable"
    SET doneCount=?
    WHERE listID=?
    """;

    await db.transaction((txn) async {
      await txn.rawUpdate(sql1, [
        task.state == 1 ? 0 : 1,
        task.listID,
        task.taskID,
      ]);
      await txn.rawUpdate(sql2, [
        task.state == 1 ? (doneCount - 1) : (doneCount + 1),
        task.listID,
      ]);
    });

    init();
    notifyListeners();
    tasklistTable.whenUpdate();
  }

  deleteTask(Task task) async {
    Tasklist list = await TasklistTable.queryTasklistExactID(task.listID);

    var db = await dbProvider.db;
    var sql1 = """
    DELETE FROM "taskTable"
    WHERE taskID=?
    """;
    var sql2 = """
    UPDATE "listTable"
    SET doneCount=?, count=?
    WHERE listID=?
    """;

    await db.transaction((txn) async {
      await txn.rawDelete(sql1, [task.taskID]);
      await txn.rawUpdate(sql2, [
        task.state == 1 ? (list.doneCount - 1) : (list.doneCount),
        list.count - 1,
        task.listID,
      ]);
    });

    init();
    notifyListeners();
    tasklistTable.whenUpdate();
  }
}
