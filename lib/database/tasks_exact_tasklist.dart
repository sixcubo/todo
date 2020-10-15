import 'package:flutter/material.dart';
import 'package:todo/database/db_provider.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

// class TasksExactTasklist extends ChangeNotifier {
//   final int tasklistID;
//
//   TasksExactTasklist(this.tasklistID);
//
//   Tasklist tasklist;
//   List<Task> data;
//
//   init() async {
//     debugPrint('初始化TasksExactListID');
//     this.tasklist = await TasklistTable.queryTasklistExactID(tasklistID);
//     this.data = await queryTasksExactTasklist();
//   }
//
//   Future<List<Task>> queryTasksExactTasklist() async {
//     var db = await dbProvider.db;
//     var sql = """
//     SELECT * FROM "taskTable"
//     WHERE "taskTable".listID = ${tasklist.tasklistID}
//     """;
//     List<Map<String, dynamic>> res = await db.rawQuery(sql);
//
//     return res.map((e) => Task.fromMap(e)).toList();
//   }
//
//   // 在TaskTable插入一条记录, 同时更新TaskList
//   insertTask(Task task) async {
//     var db = await dbProvider.db;
//     var sql1 = """
//     INSERT INTO "taskTable" (taskID, taskName, state, dateTime, listID)
//     VALUES(NULL, ?, ?, NULL, ?)
//     """;
//     var sql2 = """
//     UPDATE "listTable"
//     SET count=?
//     WHERE listID=?
//     """;
//
//     await db.transaction((txn) async {
//       await txn.rawInsert(
//         sql1,
//         [
//           task.taskName,
//           task.state,
//           task.listID,
//         ],
//       );
//
//       await txn.rawUpdate(
//         sql2,
//         [
//           tasklist.count + 1,
//           tasklist.tasklistID,
//         ],
//       );
//     });
//
//     init();
//     notifyListeners();
//     tasklistTable.whenUpdate();
//   }
//
//   updateState(Task task) async {
//     var db = await dbProvider.db;
//
//     var sql1 = """
//     UPDATE "taskTable"
//     SET state=?
//     WHERE listID=? AND taskID=?
//     """;
//     var sql2 = """
//     UPDATE "listTable"
//     SET doneCount=?
//     WHERE listID=?
//     """;
//
//     await db.transaction((txn) async {
//       await txn.rawUpdate(
//         sql1,
//         [
//           task.state == 1 ? 0 : 1,
//           task.listID,
//           task.taskID,
//         ],
//       );
//
//       await txn.rawUpdate(
//         sql2,
//         [
//           task.state == 1 ? (tasklist.doneCount - 1) : (tasklist.doneCount + 1),
//           task.listID,
//         ],
//       );
//     });
//
//     init();
//     notifyListeners();
//     tasklistTable.whenUpdate();
//   }
//
//   deleteTask(Task task) async {
//     var db = await dbProvider.db;
//
//     var sql1 = """
//     DELETE FROM "taskTable"
//     WHERE taskID=?
//     """;
//
//     var sql2 = """
//     UPDATE "listTable"
//     SET doneCount=?, count=?
//     WHERE listID=?
//     """;
//
//     await db.transaction((txn) async {
//       await txn.rawDelete(sql1, [task.taskID]);
//
//       await txn.rawUpdate(
//         sql2,
//         [
//           task.state == 1 ? (tasklist.doneCount - 1) : (tasklist.doneCount),
//           tasklist.count - 1,
//           tasklist.tasklistID,
//         ],
//       );
//     });
//
//     init();
//     notifyListeners();
//     tasklistTable.whenUpdate();
//   }
// }
