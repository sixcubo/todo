import 'package:flutter/material.dart';
import 'package:todo/database/db_manager.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo/util/diamond_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DetailPage extends StatefulWidget {
  //final int i;
  TaskList list;
  //final Color color;

  DetailPage({Key key, this.list}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController itemController = new TextEditingController();

  Color currentColor;
  Color pickerColor;

  DBManager dbManager;
  List<Task> tasks = new List();

  query() async {
    dbManager = await DBManager.getInstance();
    tasks = await dbManager.queryTasksInExactList(widget.list.listID);
    widget.list = await dbManager.queryTaskListExactID(widget.list.listID);

    setState(() {});

    debugPrint('查询');
    debugPrint('${tasks.toString()}');
  }

  //ValueChanged<Color> onColorChanged;

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    super.initState();

    currentColor = Color(widget.list.color);
    //pickerColor = currentColor;

    debugPrint('初始化');

    query();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Padding _getToolbar(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 12.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Image(
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
                          // Firestore.instance
                          //     .collection(widget.user.uid)
                          //     .document(
                          //     widget.currentList.keys.elementAt(widget.i))
                          //     .updateData(
                          //     {"color": pickerColor.value.toString()});

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

  // Widget taskElem(Task task) {
  //   return Row(
  //     children: [],
  //   );
  // }

  Widget taskElems(BuildContext context) {
    debugPrint('构建任务元素');

    if (false) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: currentColor,
        ),
      );
    } else {
      return Container(
        child: Padding(
          padding: EdgeInsets.only(top: 120.0),
          child: Column(
            children: <Widget>[
              // 标题
              Padding(
                padding: EdgeInsets.only(top: 5.0, left: 50.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // 列表名
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        widget.list.listName.toString(),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35.0),
                      ),
                    ),
                    // 删除按钮
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  "Delete: " + widget.list.listName.toString()),
                              content: Text(
                                "Are you sure you want to delete this list?",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              actions: <Widget>[
                                ButtonTheme(
                                  //minWidth: double.infinity,
                                  child: RaisedButton(
                                    elevation: 3.0,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No'),
                                    color: currentColor,
                                    textColor: const Color(0xffffffff),
                                  ),
                                ),
                                ButtonTheme(
                                  //minWidth: double.infinity,
                                  child: RaisedButton(
                                    elevation: 3.0,
                                    color: currentColor,
                                    child: Text('YES'),
                                    textColor: const Color(0xffffffff),
                                    onPressed: () async {
                                      await dbManager
                                          .deleteTaskList(widget.list);
                                      query();
                                      Navigator.pop(context); // 出栈对话框
                                      Navigator.pop(context); // 出栈卡片界面
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        FontAwesomeIcons.trash,
                        size: 25.0,
                        color: currentColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 未完成/完成
              Padding(
                padding: EdgeInsets.only(top: 5.0, left: 50.0),
                child: Row(
                  children: <Widget>[
                    new Text(
                      widget.list.doneCount.toString() +
                          " / " +
                          widget.list.count.toString(),
                      style: TextStyle(fontSize: 18.0, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              // 横线
              Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(left: 50.0),
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // 任务列表
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Color(0xFFFCFCFC),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 250,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (BuildContext ctxt, int i) {
                            // 任务项
                            return Slidable(
                              delegate: SlidableBehindDelegate(),
                              actionExtentRatio: 0.25,
                              child: GestureDetector(
                                // 点击添加或取消打勾
                                onTap: () async {
                                  await dbManager.updateState(tasks[i]);
                                  query();
                                },
                                child: Container(
                                  height: 50.0,
                                  color: tasks[i].state == 1
                                      ? Color(0xFFF0F0F0)
                                      : Color(0xFFFCFCFC),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                    decoration: TextDecoration
                                                        .lineThrough,
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
                                    await dbManager.deleteTask(tasks[i]);
                                    await query();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('构建全部');

    return Scaffold(
      //key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _getToolbar(context),
          Container(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: taskElems(context),
            ),
          ),
        ],
      ),
      // 增加按钮
      floatingActionButton: DiamondFab(
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
                        controller: itemController,
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
                          itemController.text.toString(),
                          widget.list.listID,
                        );
                        await dbManager.insertTask(widget.list, task);
                        query();
                        itemController.clear();
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
      ),
    );
  }
}
