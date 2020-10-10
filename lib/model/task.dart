import 'package:flutter/material.dart';

class Task extends ChangeNotifier{
  final int taskID;
  final String taskName;
  final int state;
  final String dateTime;
  final int listID;

  Task(
    this.taskName,
    this.listID, {
    this.dateTime,
    this.taskID,
    this.state = 0,
  });

  static Task fromMap(Map<String, dynamic> task) {
    return Task(
      task["taskName"],
      task["listID"],
      dateTime: task["dateTime"],
      taskID: task["taskID"],
      state: task["state"],
    );
  }

  String toString() {
    return "Task: $taskID, $taskName, $state, $dateTime $listID";
  }
}
