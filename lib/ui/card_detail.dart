import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardDetail extends StatelessWidget {
  final int tasklistID;

  const CardDetail(this.tasklistID, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        centerTitle: true,
        title: Selector<TasklistTable, String>(
          selector: (context, origin) =>
              origin.getTasklist(tasklistID).tasklistName,
          builder: (context, value, child) {
            debugPrint('更新详情标题');
            return Text(
              value,
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            );
          },
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 百分比条
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Consumer<TasklistTable>(
                builder: (context, value, child) {
                  var tasklist = value.getTasklist(tasklistID);
                  return Row(
                    children: [
                      Expanded(
                        flex: 16,
                        child: LinearProgressIndicator(
                          value: tasklist.count == 0
                              ? 1
                              : tasklist.doneCount / tasklist.count,
                          backgroundColor: Colors.grey.withAlpha(50),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tasklist.doneCount.toString() +
                              " / " +
                              tasklist.count.toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Consumer2<TasklistTable, TaskTable>(
              builder: (context, value1, value2, child) {
                //var tasklist = value1.getTasklist(tasklistID);
                debugPrint('重建详情任务项');
                var tasks = value2.getTasks(tasklistID);
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemExtent: 66,
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    return Slidable(
                      //controller: SlidableController(),
                      actionPane: SlidableStrechActionPane(),
                      secondaryActions: [
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () async {
                            await value2.deleteTask(tasks[i]);
                            await value1.update();
                          },
                        ),
                      ],

                      child: Container(
                        height: 66,
                        margin: EdgeInsets.fromLTRB(8, 2, 8, 2),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Spacer(),
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () async {
                                  await value2.updateState(tasks[i]);
                                  await value1.update();
                                },
                                child: Icon(
                                  tasks[i].state == 1
                                      ? FontAwesomeIcons.checkCircle
                                      : FontAwesomeIcons.circle,
                                  color: tasks[i].state == 1
                                      ? Colors.black
                                      : Colors.black26,
                                  size: 20.0,
                                ),
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              flex: 30,
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
                        ),
                      ),
                    );

                    //  GestureDetector(
                    //   onTap: () async {
                    //     await value2.updateState(tasks[i]);
                    //     await value1.update();
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         flex: 1,
                    //         child: Icon(
                    //           tasks[i].state == 1
                    //               ? FontAwesomeIcons.checkCircle
                    //               : FontAwesomeIcons.circle,
                    //           color: tasks[i].state == 1
                    //               ? Colors.black
                    //               : Colors.black26,
                    //           size: 17.0,
                    //         ),
                    //       ),
                    //       Spacer(),
                    //       Expanded(
                    //         flex: 12,
                    //         child: Text(
                    //           tasks[i].taskName,
                    //           style: TextStyle(
                    //             decoration: tasks[i].state == 1
                    //                 ? TextDecoration.lineThrough
                    //                 : null,
                    //             color: Colors.black,
                    //             fontSize: 20.0,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class TaskSlide extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(15.0),
//         ),
//       ),
//       child: Slidable(
//         actionPane: null,
//         child: Row(
//           children: [
//             Expanded(
//               flex: 1,
//               child: Icon(
//                 tasks[i].state == 1
//                     ? FontAwesomeIcons.checkCircle
//                     : FontAwesomeIcons.circle,
//                 color: tasks[i].state == 1 ? Colors.black : Colors.black26,
//                 size: 17.0,
//               ),
//             ),
//             Spacer(),
//             Expanded(
//               flex: 10,
//               child: null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
