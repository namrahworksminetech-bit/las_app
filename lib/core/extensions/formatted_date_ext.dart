extension FormattedDate on DateTime {
  // UI format → MM-DD-YYYY
  String get toformattedDDMMYYYY => "$month-$day-$year";

  // Backend format → DD-MM-YYYY
  String get toBackendDDMMYYYY =>
    "${day.toString().padLeft(2, '0')}-"
    "${month.toString().padLeft(2, '0')}-"
    "$year";

}
