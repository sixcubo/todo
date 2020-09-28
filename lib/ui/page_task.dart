import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo/database/db_manager.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';
import 'package:todo/ui/page_detail.dart';
import 'package:todo/ui/page_newlist.dart';

///TaskPage, 可以查看当前未完成的task,
///由上方的工具栏[toolBar()], 标题[header()], AddList按钮[addListBtn()], 和任务卡片构成[]

class TaskPage extends StatefulWidget {
  TaskPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  //int index = 1;
  DBManager dbManager;
  List<TaskList> listTable = new List();
  Map<int, List<Task>> allTasks = new Map();

  void query() async {
    dbManager = await DBManager.getInstance();
    listTable = await dbManager.queryTaskList();
    allTasks = await dbManager.queryAll();

    setState(() {});
  }

  @override
  initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    query();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget toolBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Image(
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
            image: new AssetImage('assets/list.png'),
          ),
        ],
      ),
    );
  }

  Widget header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Task',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Lists',
                  style: TextStyle(fontSize: 28.0, color: Colors.grey),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget addListBtn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Column(
        children: <Widget>[
          // 按钮主体
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(7.0))),
            child: IconButton(
              icon: Icon(Icons.add),
              iconSize: 30.0,
              onPressed: () async {
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => NewListPage(),
                    // 过度动画
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            ScaleTransition(
                      scale: Tween<double>(
                        begin: 1.5,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Interval(
                            0.50,
                            1.00,
                            curve: Curves.linear,
                          ),
                        ),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Interval(
                              0.00,
                              0.50,
                              curve: Curves.linear,
                            ),
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
                // TODO: 更好的刷新页面的方法
                query();
              },
            ),
          ),
          // 按钮文字
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Add List',
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: 抽离卡片部件
  List<GestureDetector> getExistItems() {
    Column getTaskInfo(int listID) {
      List<Task> tasks = allTasks[listID];
      if (tasks.isNotEmpty) {
        debugPrint('listID: ${allTasks[listID]} tasks非空');

        return Column(
          children: <Widget>[
            SizedBox(
              height: 220.0,
              child: ListView.builder(
                //physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (BuildContext ctx, int i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // check框
                      Icon(
                        //DB.values.elementAt(index).elementAt(i).state
                        tasks[i].state == 1
                            ? FontAwesomeIcons.checkCircle
                            : FontAwesomeIcons.circle,
                        color:
                            tasks[i].state == 1 ? Colors.white70 : Colors.white,
                        size: 14.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                      ),
                      Flexible(
                        child: Text(
                          //DB.values.elementAt(listID).elementAt(i).taskName,
                          tasks[i].taskName,
                          style: tasks[i].state == 1
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.white70,
                                  fontSize: 17.0,
                                )
                              : TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      } else {
        debugPrint('allTask空');
        return null;
      }
    }

    var cards = List.generate(
      listTable.length, // 任务列表总数
      // 遍历所有任务列表, 每个列表生成一个card
      (int index) {
        TaskList list = listTable[index];

        return GestureDetector(
          // TODO: to finish optap
          onTap: () async {
            await Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => DetailPage(
                  //i: index,
                  list: list,
                  //color: Color(list.color),
                ),
                // 动画
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        ScaleTransition(
                  scale: Tween<double>(
                    begin: 1.5,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Interval(
                        0.50,
                        1.00,
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Interval(
                          0.00,
                          0.50,
                          curve: Curves.linear,
                        ),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            );

            // TODO: 更好的刷新页面的方法
            query();

            debugPrint('从详情返回');
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            color: Color(list.color),
            child: Container(
              width: 220.0,
              child: Column(
                children: [
                  // 列表名
                  Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
                    child: Container(
                      child: Text(
                        list.listName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.0,
                        ),
                      ),
                    ),
                  ),
                  // 一条横线
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.only(left: 30.0, right: 30.0),
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 列表项
                  Padding(
                    padding: EdgeInsets.only(top: 30.0, left: 15.0, right: 5.0),
                    child: getTaskInfo(list.listID),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return cards;
  }

  Widget listCards(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Container(
        height: 360.0,
        padding: EdgeInsets.only(bottom: 25.0),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: Builder(
            builder: (BuildContext context) {
              if (listTable.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ),
                );
              }
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(left: 40.0, right: 40.0),
                scrollDirection: Axis.horizontal,
                children: getExistItems(),
                // children: getExpenseItems(snapshot),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              toolBar(context),
              header(context),
              addListBtn(context),
            ],
          ),
          listCards(context),
        ],
      ),
    );
  }
}
