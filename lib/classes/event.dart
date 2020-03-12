import 'package:flutter/material.dart';

class Event implements EventInterface {
  final DateTime date;
  final Widget icon;
  final Widget dot;

  Event({
    this.date,
    this.icon,
    this.dot,
  }) : assert(date != null);

  @override
  bool operator ==(dynamic other) {
    return this.date == other.date &&
        this.icon == other.icon &&
        this.dot == other.dot;
  }

  @override
  int get hashCode => hashValues(date, icon);

  @override
  DateTime getDate() {
    return date;
  }

  @override
  Widget getDot() {
    return dot;
  }

  @override
  Widget getIcon() {
    return icon;
  }
}

abstract class EventInterface {
  DateTime getDate();
  Widget getIcon();
  Widget getDot();
}
