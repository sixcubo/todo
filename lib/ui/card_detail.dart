import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/model/task.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

enum TaskCardSettings { edit_name, edit_color, delete }

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

  Future<bool> showEditNameDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit tasklist name"),
          content: TextField(
            controller: _textCtrler,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.drive_file_rename_outline),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _textCtrler.clear();
                Navigator.of(context).pop();
              },
            ),
            Consumer<TasklistTable>(
              builder: (context, value, child) => FlatButton(
                child: Text("Rename"),
                onPressed: () async {
                  var name = _textCtrler.text.trim();
                  await value.updateName(tasklistID, name);
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

  Future<bool> showEditColorDialog(BuildContext context) {
    //Color currentColor = Color(0xff6633ff);
    Color pickerColor = Color(0xff6633ff);

    changeColor(Color color) {
      pickerColor = color;
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(5.0),
                topRight: const Radius.circular(5.0),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer<TasklistTable>(
              builder: (context, value, child) {
                return FlatButton(
                  child: Text('Got it'),
                  onPressed: () async {
                    await value.updateColor(tasklistID, pickerColor.value);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete tasklist"),
          content: Text('Delete this tasklist?'),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer2<TasklistTable, TaskTable>(
              builder: (context, value, value2, child) => FlatButton(
                child: Text("Yes"),
                onPressed: () async {
                  ///完成此回调的操作后, 详情页(CardDetail类)中的Consumer也会收到通知,
                  ///并完成更新, 而此时此详情页所依赖的tasklist已经被删除,
                  ///因此Consumer/Selector中的代码使用操作符 ?. 和 ?? 防止null访问异常.
                  await value.deleteTasklist(tasklistID);
                  debugPrint('delete over');
                  Navigator.of(context).pop(true);
                  Navigator.of(context).pop(true);
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
        elevation: 0,
        centerTitle: true,
        title: Selector<TasklistTable, String>(
          selector: (context, origin) {
            return origin.getTasklist(tasklistID)?.tasklistName ?? "";
          },
          builder: (context, value, child) {
            //debugPrint('更新详情标题');
            return Text(
              value,
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            itemBuilder: (context) {
              return <PopupMenuEntry<TaskCardSettings>>[
                PopupMenuItem(
                  child: Text("Edit Name"),
                  value: TaskCardSettings.edit_name,
                ),
                PopupMenuItem(
                  child: Text("Edit Color"),
                  value: TaskCardSettings.edit_color,
                ),
                PopupMenuItem(
                  child: Text("Delete"),
                  value: TaskCardSettings.delete,
                ),
              ];
            },
            onSelected: (setting) {
              switch (setting) {
                case TaskCardSettings.edit_name:
                  debugPrint("edit name clicked");
                  showEditNameDialog(context);
                  break;
                case TaskCardSettings.edit_color:
                  debugPrint("edit color clicked");
                  showEditColorDialog(context);
                  break;
                case TaskCardSettings.delete:
                  debugPrint("delete clicked");
                  showDeleteDialog(context);
                  break;
              }
            },
          ),
        ],
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
                    color: Color((value.getTasklist(tasklistID)?.color) ?? 0),
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
                      return tasklist != null
                          ? Row(
                              children: [
                                Expanded(
                                  flex: 16,
                                  child: LinearProgressIndicator(
                                    value: tasklist.count == 0
                                        ? 1
                                        : tasklist.doneCount / tasklist.count,
                                    backgroundColor: Colors.grey.withAlpha(50),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black54),
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          : Container();
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
