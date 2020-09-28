
class TaskList {
  final int listID;
  final String listName;
  final int color;
  final int count;
  final int doneCount;

  TaskList(
    this.listName,
    this.color, [
    this.count = 0,
    this.doneCount = 0,
    this.listID,
  ]);

  static TaskList fromMap(Map<String, dynamic> list) {
    return TaskList(
      list["listName"],
      list["color"],
      list["count"],
      list["doneCount"],
      list["listID"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "listID": listID,
      "listName": listName,
      "color": color,
      "count": count,
      "doneCount": doneCount,
    };
  }

  String toString() {
    return "TaskList: $listID, $listName, $color, $count, $doneCount";
  }
}
