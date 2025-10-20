extension StringExt on String {
  bool get isBlank => trim().isEmpty;
  String get capitalized => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
