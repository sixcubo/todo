import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_list.dart';
import 'package:todo/ui/card_detail.dart';
import 'package:todo/de/detail_page.dart';
import 'package:todo/ui/newlist_page.dart';
import 'package:todo/ui/widget/time_bar.dart';
import 'package:todo/util/fixed_scrollphysics.dart';
import 'package:todo/util/changeable_bg.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

///TaskPage, 可以查看当前未完成的task,
///由上方的工具栏[toolBar()], 标题[header()], AddList按钮[addListBtn()], 和任务卡片构成[]

class TaskPage extends StatefulWidget {
  TaskPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollCtrler;
  ColorTween colorTween;
  ChangeableBG<Color> colorBG;

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    scrollCtrler = new ScrollController();
    colorTween = new ColorTween();
    colorBG = new ChangeableBG<Color>();

    super.initState();
  }

  Widget addListBtn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          // 按钮主体
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.black54),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: IconButton(
              icon: Icon(Icons.add),
              iconSize: 30.0,
              onPressed: () async {
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 2000),
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
                            0.00,
                            0.50,
                            curve: Curves.bounceOut,
                          ),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
          // 按钮文字
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Add List',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildCards(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 25),
        child: Selector<TasklistTable, List<Tasklist>>(
          // 仅当tasklists数量改变时, rebuild
          shouldRebuild: (previous, next) => previous.length != next.length,
          selector: (ctx, origin) => origin.data,
          builder: (context, value, child) {
            //var tasklists = value.data;
            //debugPrint('重建详情任务项\n卡片数量:${tasklists.length}');
            whenScroll() {
              double index = scrollCtrler.offset /
                  scrollCtrler.position.maxScrollExtent *
                  (value.length - 1);

              colorTween.begin =
                  Color(value[(index.floor()) % value.length].color);
              colorTween.end =
                  Color(value[(index.floor() + 1) % value.length].color);
              colorBG.value = colorTween.transform(index % 1);
            }

            return ListView.builder(
              controller: scrollCtrler
                ..removeListener(whenScroll)
                ..addListener(whenScroll),
              physics: FixedScrollPhysics(value),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 40.0, right: 40.0),
              itemCount: value.length,
              itemBuilder: (context, i) {
                return TasklistCard(value[i].tasklistID);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint('重建');
    return Stack(
      children: [
        ChangeNotifierProvider<ChangeableBG>.value(
          value: colorBG,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: Provider.of<ChangeableBG>(context).value,
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'Task Card',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              TimeBar(),
              addListBtn(context),
              _buildCards(context),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    scrollCtrler.dispose();

    super.dispose();
  }
}

// 任务卡片类
class TasklistCard extends StatelessWidget {
  final int tasklistID;

  TasklistCard(this.tasklistID, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1000),
            pageBuilder: (_, animation, __) {
              return FadeTransition(
                opacity: animation,
                child: CardDetail(tasklistID),
              );
            },
          ),
        );
      },
      child: Stack(
        children: [
          Hero(
            tag: 'hero_background_$tasklistID',
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 15),
              color: Color.fromARGB(190, 255, 255, 230),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width - 80,
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              ),
            ),
          ),
          Card(
            //  margin: EdgeInsets.all(10.0),
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              child: Column(
                children: [
                  // 标题
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Selector<TasklistTable, String>(
                        // 选出 标题
                        selector: (ctx, origin) =>
                            origin.getTasklist(tasklistID).tasklistName,
                        builder: (context, value, child) {
                          //debugPrint('标题${value}');
                          return Text(
                            value,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 百分比
                  Expanded(
                    flex: 1,
                    child: Selector<TasklistTable, Tasklist>(
                      // 选出 tasklist
                      selector: (ctx, origin) => origin.getTasklist(tasklistID),
                      builder: (context, value, child) {
                        //var tasklist = value.getTasklist(tasklistID);
                        double donePercent = value.count == 0
                            ? 1
                            : value.doneCount / value.count;
                        return Row(
                          children: <Widget>[
                            Expanded(
                              flex: 15,
                              child: LinearProgressIndicator(
                                value: donePercent,
                                backgroundColor: Colors.grey.withAlpha(50),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(value.color)),
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              flex: 3,
                              child: Text(
                                value.doneCount.toString() +
                                    " / " +
                                    value.count.toString(),
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // 列表项
                  Expanded(
                    flex: 8,
                    child: Selector<TaskTable, List<Task>>(
                      // 选出 tasks
                      selector: (ctx, origin) => origin.getTasks(tasklistID),
                      builder: (context, value, child) {
                        return ListView.builder(
                          itemExtent: 35,
                          itemCount: value.length,
                          itemBuilder: (context, i) {
                            return Row(
                              children: [
                                // check框
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    value[i].state == 1
                                        ? FontAwesomeIcons.checkCircle
                                        : FontAwesomeIcons.circle,
                                    color: value[i].state == 1
                                        ? Colors.black
                                        : Colors.black26,
                                    size: 17.0,
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    value[i].taskName,
                                    style: TextStyle(
                                      decoration: value[i].state == 1
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget header(BuildContext context) {
//   return Padding(
//     padding: EdgeInsets.only(top: 30),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 1,
//           child: Container(
//             color: Colors.grey,
//             height: 1.5,
//           ),
//         ),
//         Expanded(
//           flex: 2,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'Task',
//                 style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 'Lists',
//                 style: TextStyle(fontSize: 28.0, color: Colors.grey),
//               )
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Container(
//             color: Colors.grey,
//             height: 1.5,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// List<GestureDetector> getExistItems() {
//   Column getTaskInfo(int listID) {
//     List<Task> tasks = allTasks[listID];
//     if (tasks.isNotEmpty) {
//       return Column(
//         children: <Widget>[
//           SizedBox(
//             height: 220.0,
//             child: ListView.builder(
//               //physics: const NeverScrollableScrollPhysics(),
//               itemCount: tasks.length,
//               itemBuilder: (BuildContext ctx, int i) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     // check框
//                     Icon(
//                       //DB.values.elementAt(index).elementAt(i).state
//                       tasks[i].state == 1
//                           ? FontAwesomeIcons.checkCircle
//                           : FontAwesomeIcons.circle,
//                       color:
//                           tasks[i].state == 1 ? Colors.white70 : Colors.white,
//                       size: 14.0,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 10.0),
//                     ),
//                     Flexible(
//                       child: Text(
//                         //DB.values.elementAt(listID).elementAt(i).taskName,
//                         tasks[i].taskName,
//                         style: tasks[i].state == 1
//                             ? TextStyle(
//                                 decoration: TextDecoration.lineThrough,
//                                 color: Colors.white70,
//                                 fontSize: 17.0,
//                               )
//                             : TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 17.0,
//                               ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     } else {
//       return null;
//     }
//   }
//
//   var cards = List.generate(
//     listTable.length, // 任务列表总数
//     // 遍历所有任务列表, 每个列表生成一个card
//     (int index) {
//       TaskList list = listTable[index];
//
//       return GestureDetector(
//         // TODO: to finish ontap
//         onTap: () async {
//           await Navigator.of(context).push(
//             PageRouteBuilder(
//               pageBuilder: (_, __, ___) => DetailPage(
//                 //i: index,
//                 list: list,
//                 //color: Color(list.color),
//               ),
//               // 动画
//               transitionsBuilder:
//                   (context, animation, secondaryAnimation, child) =>
//                       ScaleTransition(
//                 scale: Tween<double>(
//                   begin: 1.5,
//                   end: 1.0,
//                 ).animate(
//                   CurvedAnimation(
//                     parent: animation,
//                     curve: Interval(
//                       0.50,
//                       1.00,
//                       curve: Curves.linear,
//                     ),
//                   ),
//                 ),
//                 child: ScaleTransition(
//                   scale: Tween<double>(
//                     begin: 0.0,
//                     end: 1.0,
//                   ).animate(
//                     CurvedAnimation(
//                       parent: animation,
//                       curve: Interval(
//                         0.00,
//                         0.50,
//                         curve: Curves.linear,
//                       ),
//                     ),
//                   ),
//                   child: child,
//                 ),
//               ),
//             ),
//           );
//
//           // TODO: 更好的刷新页面的方法
//           query();
//
//           debugPrint('从详情返回');
//         },
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(8.0),
//             ),
//           ),
//           color: Color(list.color),
//           child: Container(
//             width: 220.0,
//             child: Column(
//               children: [
//                 // 列表名
//                 Padding(
//                   padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
//                   child: Container(
//                     child: Text(
//                       list.listName,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 19.0,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // 一条横线
//                 Padding(
//                   padding: EdgeInsets.only(top: 5.0),
//                   child: Row(
//                     children: <Widget>[
//                       Expanded(
//                         flex: 2,
//                         child: Container(
//                           margin: EdgeInsets.only(left: 30.0, right: 30.0),
//                           color: Colors.white,
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // 列表项
//                 Padding(
//                   padding: EdgeInsets.only(top: 30.0, left: 15.0, right: 5.0),
//                   child: getTaskInfo(list.listID),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
//
//   return cards;
// }
//
// Widget listCards(BuildContext context) {
//   return Expanded(
//     child: Container(
//       //height: 450.0,
//       padding: EdgeInsets.only(top: 30.0, bottom: 50),
//       child: NotificationListener<OverscrollIndicatorNotification>(
//         onNotification: (overscroll) {
//           overscroll.disallowGlow();
//         },
//         child: Builder(
//           builder: (BuildContext context) {
//             if (listTable.isEmpty) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   backgroundColor: Colors.blue,
//                 ),
//               );
//             }
//             return Center(
//               child: ListView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.only(left: 40.0, right: 40.0),
//                 scrollDirection: Axis.horizontal,
//                 children: getExistItems(),
//                 // children: getExpenseItems(snapshot),
//               ),
//             );
//           },
//         ),
//       ),
//     ),
//   );
// }
