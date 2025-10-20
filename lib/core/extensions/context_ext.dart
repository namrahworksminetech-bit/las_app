import 'package:flutter/material.dart';
// file: context_ext.dart
extension ContextThemeExt on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  TextTheme get appTextTheme => appTheme.textTheme;
}

// file: context_navigation_ext.dart
extension ContextNavExt on BuildContext {
  void push(Widget page) => Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));
}
