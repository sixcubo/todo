import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

Color randomColor({int r = 255, int g = 255, int b = 255, a = 255}) {
  if (r == 0 || g == 0 || b == 0) return Colors.black;
  if (a == 0) return Colors.white;
  return Color.fromARGB(
    a,
    r != 255 ? r : Random.secure().nextInt(r),
    g != 255 ? g : Random.secure().nextInt(g),
    b != 255 ? b : Random.secure().nextInt(b),
  );
}

class TimeBar extends StatefulWidget {
  @override
  _TimeBarState createState() => _TimeBarState();
}

class _TimeBarState extends State<TimeBar> {
  DateTime _dt;
  List<String> _weekday = ['MON', 'TUES', 'WED', 'THUS', 'FRI', 'SAT', 'SUN'];

  Color _waveColor;
  Color _boxBackgroundColor;

  @override
  void initState() {
    _dt = DateTime.now();

    _waveColor = randomColor(a: 180);
    _boxBackgroundColor = randomColor(a: 200);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width - 80,
      margin: EdgeInsets.symmetric(horizontal: 40),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        onTap: () {
          setState(() {
            _waveColor = randomColor(a: 180);
            _boxBackgroundColor = randomColor(a: 200);
            // debugPrint('$_waveColor');
            // debugPrint('$_boxBackgroundColor');
          });
        },
        child: TextLiquidFill(
          key: ValueKey(_waveColor),
          loadDuration: Duration(seconds: 10),
          waveDuration: Duration(seconds: 3),
          boxHeight: 100.0,
          waveColor: _waveColor,
          boxBackgroundColor: _boxBackgroundColor,
          text: '${_weekday[_dt.weekday - 1]}',
          textStyle: TextStyle(
            fontSize: 80.0,
            fontWeight: FontWeight.bold,
            shadows: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 3,
              )
            ],
          ),
        ),
      ),
    );
  }
}
