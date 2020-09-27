class Task {
  final int taskID;
  final String taskName;
  final bool state;
  final DateTime dateTime;
  final int listID;

  Task(
    this.taskName,
    this.state,
    this.listID, [
    this.dateTime,
    this.taskID,
  ]);

  String toString() {
    return "Task: $taskID, $taskName, $state, $dateTime $listID";
  }
}
