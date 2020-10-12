import 'package:flutter/cupertino.dart';

class ChangeableBG<T> with ChangeNotifier {
  T _value;

  T get value => this._value;

  set value(T v) {
    this._value = v;
    notifyListeners();
  }
}
