import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/database/db_provider.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo/ui/detail_page.dart';
import 'package:provider/provider.dart';
import 'package:todo/database/tasks_exact_tasklist.dart';

class TasklistCard extends StatelessWidget {
  final Tasklist tasklist;

  TasklistCard(this.tasklist, {Key key}) : super(key: key);

  // // 从数据库请求数据
  // Future<TasksExactTasklist> query() async {
  //   TasksExactTasklist tasks = TasksExactTasklist(taskListID);
  //   await tasks.init();
  //   return tasks;
  // }

  // 构建任务信息
  ListView tasksInfo(List<Task> tasks) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 0),
      itemCount: tasks.length,
      itemExtent: 35,
      itemBuilder: (context, i) {
        return Row(
          children: [
            // check框
            Expanded(
              flex: 1,
              child: Icon(
                tasks[i].state == 1
                    ? FontAwesomeIcons.checkCircle
                    : FontAwesomeIcons.circle,
                color: tasks[i].state == 1 ? Colors.black : Colors.black26,
                size: 17.0,
              ),
            ),
            Spacer(),
            Expanded(
              flex: 12,
              child: Text(
                tasks[i].taskName,
                style: TextStyle(
                  decoration: tasks[i].state == 1
                      ? TextDecoration.lineThrough
                      : null,
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<TasksExactTasklist>(
    //     //   future: query(),
    //     //   builder: (context, snapshot) {
    //     //     if (snapshot.connectionState == ConnectionState.done) {
    //     //       return ChangeNotifierProvider<TasksExactTasklist>(
    //     //         create: (_) => snapshot.data,
    //     //         child: Consumer<TasksExactTasklist>(
    //     //           builder: (context, value, child) =>

    double donePercent = tasklist.doneCount / tasklist.count;
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 1000),
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return Consumer<TaskTable>(
                builder: (context, value, child) {
                  //var tasks = value.data[tasklist.tasklistID];
                  return DetailPage(tasklist, value);
                },
              );
            },
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width - 80,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
            child: Column(
              children: [
                // 标题
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tasklist.tasklistName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // 百分比
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 16,
                        child: LinearProgressIndicator(
                          value: donePercent,
                          backgroundColor: Colors.grey.withAlpha(50),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(tasklist.color)),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (donePercent * 100).round().toString() + "%",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // 列表项
                Expanded(
                  flex: 8,
                  child: Consumer<TaskTable>(
                    builder: (context, value, child) {
                      var tasks = value.data[tasklist.tasklistID];
                      return tasksInfo(tasks);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    //   ),
    // );
    //     } else {
    //       return Center(
    //         child: CircularProgressIndicator(
    //           backgroundColor: Colors.blue,
    //         ),
    //       );
    //     }
    //   },
    // );
  }
}
