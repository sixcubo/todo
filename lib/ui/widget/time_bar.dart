import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeBar extends StatefulWidget {
  @override
  _TimeBarState createState() => _TimeBarState();
}

class _TimeBarState extends State<TimeBar> {
  DateTime dt;

  @override
  void initState() {
    dt = DateTime.now();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      child: SizedBox(
        height: 50,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "  ${dt.month}月 ${dt.day}日 ",
                style: TextStyle(color: Colors.blue, fontSize: 30, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: "星期${dt.weekday}",
                style: TextStyle(color: Colors.green, fontSize: 23),
              )
            ],
          ),
        ),
      ),
    );
  }
}
