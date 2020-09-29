import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:todo/ui/page_done.dart';
import 'package:todo/ui/page_task.dart';

///主界面, 包括底部导航栏和当前页面, 共有三个页面可以切换, 页面位于[_children].

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    //DonePage(),
    TaskPage(),
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
              icon: Icon(FontAwesomeIcons.calendarCheck), title: Text("")),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendar), title: Text("")),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.slidersH), title: Text("")),
        ],
      ),
    );
  }
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      home: HomePage(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

void main() {
  runApp(ToDoApp());
}
