import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/database/db_provider.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/database/tasks_exact_tasklist.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo/util/diamond_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final Tasklist tasklist;
  final TaskTable taskTable;

  DetailPage(this.tasklist, this.taskTable, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // List<Task> _tasks;
  // Tasklist _tasklist;
  var tasks;


  TextEditingController editController;

  Color currentColor;
  Color pickerColor;

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    tasks = taskTable.data[widget.tasklist.tasklistID];
    // _tasks = widget.tasksExactTasklist.data;
    // _tasklist = widget.tasksExactTasklist.tasklist;

    editController = new TextEditingController();
    currentColor = Color(widget.tasklist.color);

    super.initState();
  }

  Padding _getToolbar(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 12.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(
              width: 35.0,
              height: 35.0,
              fit: BoxFit.cover,
              image: new AssetImage('assets/list.png')),
          RaisedButton(
            elevation: 3.0,
            onPressed: () {
              pickerColor = currentColor;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                        //enableLabel: true,
                        colorPickerWidth: 1000.0,
                        pickerAreaHeightPercent: 0.7,
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Got it'),
                        onPressed: () {
                          setState(() => currentColor = pickerColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Color'),
            color: currentColor,
            textColor: const Color(0xffffffff),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: new Icon(
              Icons.close,
              size: 40.0,
              color: currentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget header(BuildContext context) {
    double donePercent = widget.tasklist.doneCount /
        widget.tasklist.count;

    return Expanded(
      //padding: EdgeInsets.only(top: 20.0),
      flex: 2,
      child: Column(
        children: [
          // 标题
          // Padding(
          //   padding: EdgeInsets.only(top: 5.0, left: 50.0, right: 20.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       // 列表名
          //       Flexible(
          //         fit: FlexFit.loose,
          //         child: Text(
          //           _tasklist.tasklistName.toString(),
          //           softWrap: true,
          //           overflow: TextOverflow.fade,
          //           style: TextStyle(
          //               fontWeight: FontWeight.bold, fontSize: 35.0),
          //         ),
          //       ),
          //       // 删除按钮
          //       GestureDetector(
          //         onTap: () {
          //           showDialog(
          //             context: context,
          //             builder: (BuildContext context) {
          //               return AlertDialog(
          //                 title: Text(
          //                     "Delete: " + _tasklist.tasklistName.toString()),
          //                 content: Text(
          //                   "Are you sure you want to delete this list?",
          //                   style: TextStyle(fontWeight: FontWeight.w400),
          //                 ),
          //                 actions: <Widget>[
          //                   ButtonTheme(
          //                     //minWidth: double.infinity,
          //                     child: RaisedButton(
          //                       elevation: 3.0,
          //                       onPressed: () {
          //                         Navigator.pop(context);
          //                       },
          //                       child: Text('No'),
          //                       color: currentColor,
          //                       textColor: const Color(0xffffffff),
          //                     ),
          //                   ),
          //                   ButtonTheme(
          //                     //minWidth: double.infinity,
          //                     child: RaisedButton(
          //                       elevation: 3.0,
          //                       color: currentColor,
          //                       child: Text('YES'),
          //                       textColor: const Color(0xffffffff),
          //                       // TODO:
          //                       onPressed: () async {
          //                         await tasklistTable
          //                             .deleteTasklist(_tasklist);
          //                         //query();
          //                         Navigator.pop(context); // 出栈对话框
          //                         Navigator.pop(context); // 出栈卡片界面
          //                       },
          //                     ),
          //                   ),
          //                 ],
          //               );
          //             },
          //           );
          //         },
          //         child: Icon(
          //           FontAwesomeIcons.trash,
          //           size: 25.0,
          //           color: currentColor,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // 未完成/完成
          Expanded(
            flex: 1,
            //padding: EdgeInsets.only(top: 5.0, left: 50.0),
            child: Text(
              widget.tasklist.doneCount.toString() +
                  " / " +
                  widget.tasklist.count.toString(),
              style: TextStyle(fontSize: 18.0, color: Colors.black54),
            ),
          ),
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
                        Color(widget.tasklist.color)),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 2,
                  child: Text(
                    (donePercent * 100).round().toString() + "%",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 横线
          // Padding(
          //   padding: EdgeInsets.only(top: 5.0),
          //   child: Row(
          //     children: <Widget>[
          //       Expanded(
          //         flex: 2,
          //         child: Container(
          //           margin: EdgeInsets.only(left: 50.0),
          //           color: Colors.grey,
          //           height: 1.5,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget taskElems(BuildContext context) {


    return Expanded(
      flex: 10,
      child: Container(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (BuildContext ctxt, int i) {
            // 任务项
            return Slidable(
              delegate: SlidableBehindDelegate(),
              actionExtentRatio: 0.25,
              child: GestureDetector(
                // 点击添加或取消对号
                onTap: () async {
                  await widget.taskTable.updateState(tasks[i]);
                  //query();
                },
                child: Container(
                  height: 50.0,
                  color: tasks[i].state == 1
                      ? Color(0xFFF0F0F0)
                      : Color(0xFFFCFCFC),
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          tasks[i].state == 1
                              ? FontAwesomeIcons.checkSquare
                              : FontAwesomeIcons.square,
                          color: tasks[i].state == 1
                              ? currentColor
                              : Colors.black,
                          size: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.0),
                        ),
                        Flexible(
                          child: Text(
                            tasks[i].taskName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: tasks[i].state == 1
                                ? TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: currentColor,
                                    fontSize: 27.0,
                                  )
                                : TextStyle(
                                    color: Colors.black,
                                    fontSize: 27.0,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 右划删除按钮
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () async {
                    await widget.taskTable.deleteTask(tasks[i]);
                    //await query();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget addTaskBtn(BuildContext context) {
    return DiamondFab(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: currentColor)),
                        labelText: "Item",
                        hintText: "Item",
                        contentPadding: EdgeInsets.only(
                            left: 16.0, top: 20.0, right: 16.0, bottom: 5.0),
                      ),
                      controller: editController,
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                ButtonTheme(
                  //minWidth: double.infinity,
                  child: RaisedButton(
                    elevation: 3.0,
                    color: currentColor,
                    textColor: const Color(0xffffffff),
                    child: Text('Add'),
                    onPressed: () async {
                      Task task = Task(
                        editController.text.toString(),
                        widget.tasklist.tasklistID,
                      );
                      await widget.taskTable.insertTask(task);
                      //query();
                      editController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            );
          },
        );
      },
      child: Icon(Icons.add),
      backgroundColor: currentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.tasklist.tasklistName),
        backgroundColor: Color(widget.tasklist.color),
        elevation: 0,
      ),
      body: Column(
        children: [
          //_getToolbar(context),
          header(context),
          taskElems(context),
        ],
      ),
      floatingActionButton: addTaskBtn(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
