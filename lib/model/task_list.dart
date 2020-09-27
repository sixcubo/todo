import 'package:flutter/cupertino.dart';

class TaskList {
  final int listID;
  final String listName;
  final Color color;
  final int count;
  final int doneCount;

  TaskList(
    this.listName,
    this.color, [
    this.count = 0,
    this.doneCount = 0,
    this.listID,
  ]);

  String toString() {
    return "TaskList: $listName, $color, $count, $doneCount";
  }
}
