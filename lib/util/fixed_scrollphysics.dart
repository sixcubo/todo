import 'package:flutter/material.dart';
import 'package:todo/model/task_list.dart';

class FixedScrollPhysics extends ScrollPhysics {
  final List<Tasklist> tasklists;

  FixedScrollPhysics(this.tasklists, {ScrollPhysics parent})
      : super(parent: parent);

  @override
  FixedScrollPhysics applyTo(ScrollPhysics ancestor) {
    return FixedScrollPhysics(tasklists, parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels /
        (position.maxScrollExtent / (tasklists.length.toDouble() - 1));
  }

  double _getPixels(ScrollPosition position, double page) {
    return page *
        (position.maxScrollExtent / (tasklists.length.toDouble() - 1));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }

    return null;
  }
}