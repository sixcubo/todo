import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/model/task.dart';

class CardDetail extends StatelessWidget {
  final int tasklistID;
  CardDetail(this.tasklistID, {Key key}) : super(key: key);

  final TextEditingController _textCtrler = TextEditingController();

  Future<bool> showAddDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add task"),
          content: TextField(
            controller: _textCtrler,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.assignment_turned_in_outlined),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _textCtrler.clear();
                Navigator.of(context).pop();
              }, //关闭对话框
            ),
            Consumer2<TasklistTable, TaskTable>(
              builder: (context, value, value2, child) => FlatButton(
                child: Text("Add"),
                onPressed: () async {
                  var task = Task(_textCtrler.text.trim(), tasklistID);
                  await value2.insertTask(task);
                  await value.update();
                  _textCtrler.clear();
                  Navigator.of(context).pop(true); //关闭对话框
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
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
        //backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -_size.width / 2,
            right: -_size.width / 3,
            width: _size.width * 1,
            height: _size.width * 1,
            child: Hero(
              tag: 'hero_background_$tasklistID',
              child: Consumer<TasklistTable>(
                builder: (context, value, child) => Container(
                  decoration: BoxDecoration(
                    color: Color(value.getTasklist(tasklistID).color),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Column(
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
              // 列表项
              Expanded(
                flex: 10,
                child: Consumer2<TasklistTable, TaskTable>(
                  builder: (context, value1, value2, child) {
                    debugPrint('重建详情任务项');
                    var tasks = value2.getTasks(tasklistID);
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemExtent: 66,
                      itemCount: tasks.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: EdgeInsets.fromLTRB(8, 2, 8, 2),
                          child: Slidable(
                            actionPane: SlidableStrechActionPane(),
                            secondaryActions: [
                              Container(
                                margin: EdgeInsets.only(left: 4),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 3),
                                      blurRadius: 3,
                                    )
                                  ],
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: IconSlideAction(
                                  color: Colors.transparent,
                                  icon: Icons.delete,
                                  onTap: () async {
                                    await value2.deleteTask(tasks[i]);
                                    await value1.update();
                                  },
                                ),
                              ),
                            ],
                            child: Container(
                              height: 66,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 3),
                                    blurRadius: 3,
                                  )
                                ],
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
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          showAddDialog(context);
        },
      ),
    );
  }
}
