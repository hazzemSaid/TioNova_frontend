// make a provider for mainlayout index
//with chnage notifier

import 'package:flutter/material.dart';

class IndexMainLayout extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }
}
