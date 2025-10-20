import 'package:flutter/widgets.dart';
extension NumPadding on num {
  SizedBox get vBox => SizedBox(height: toDouble());
  SizedBox get hBox => SizedBox(width: toDouble());
}
