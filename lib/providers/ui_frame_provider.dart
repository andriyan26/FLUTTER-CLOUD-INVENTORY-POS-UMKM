import 'package:flutter/material.dart';

enum ViewportMode {
  iphone13,
  tablet,
  desktopFull,
}

class UiFrameProvider extends ChangeNotifier {
  ViewportMode _viewportMode = ViewportMode.iphone13;

  ViewportMode get viewportMode => _viewportMode;

  void setViewportMode(ViewportMode mode) {
    if (_viewportMode == mode) return;
    _viewportMode = mode;
    notifyListeners();
  }
}
