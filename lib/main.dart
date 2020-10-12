import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo/database/task_table.dart';
import 'package:todo/database/tasklist_table.dart';
import 'package:todo/database/tasks_exact_tasklist.dart';

import 'package:todo/ui/done_page.dart';
import 'package:todo/ui/task_page.dart';

import 'package:provider/provider.dart';

///主界面, 包括底部导航栏和当前页面, 共有三个页面可以切换, 页面位于[_children].

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    TaskPage(),
    DonePage(),
    //SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Colors.deepPurple,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendar), label: ''),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendarCheck), label: ''),
          //BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.slidersH), label: ''),
        ],
      ),
    );
  }
}

class ToDoApp extends StatelessWidget {
  Future<List> query() async {
    var tasklistTable = TasklistTable();
    var taskTable = TaskTable();
    
    await tasklistTable.init();
    await taskTable.init();
    return [tasklistTable, taskTable];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: query(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<TasklistTable>.value(value: snapshot.data[0]),
              ChangeNotifierProvider<TaskTable>.value(value: snapshot.data[1]),
            ],
            child: MaterialApp(
              title: 'ToDo',
              home: HomePage(),
              theme: ThemeData(primarySwatch: Colors.blue),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        }
      },
    );
  }
}

void main() {
  runApp(ToDoApp());
}
