import 'package:flutter/material.dart';

class Tasklist extends ChangeNotifier{
  final int tasklistID;
  final String tasklistName;
  final int color;
  final int count;
  final int doneCount;

  Tasklist(
    this.tasklistName,
    this.color, [
    this.count = 0,
    this.doneCount = 0,
    this.tasklistID,
  ]);

  static Tasklist fromMap(Map<String, dynamic> list) {
    return Tasklist(
      list["listName"],
      list["color"],
      list["count"],
      list["doneCount"],
      list["listID"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "listID": tasklistID,
      "listName": tasklistName,
      "color": color,
      "count": count,
      "doneCount": doneCount,
    };
  }

  String toString() {
    return "TaskList: $tasklistID, $tasklistName, $color, $count, $doneCount";
  }
}
