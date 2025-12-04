extension StringExt on String {
  bool get isBlank => trim().isEmpty;

  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  String toIndianFormat() {
        double number = double.tryParse(this) ?? 0;
    String formattedNumber = number.toStringAsFixed(2);

    List<String> parts = formattedNumber.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    if (integerPart.length > 3) {
      String lastThree = integerPart.substring(integerPart.length - 3);
      String remaining = integerPart.substring(0, integerPart.length - 3);
      remaining = remaining.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+$)'), (
        Match match,
      ) {
        return '${match[1]},';
      });
      integerPart = '$remaining,$lastThree';
    }

    return int.parse(decimalPart) > 1 ? '$integerPart.$decimalPart' : integerPart;
  }

  String maskNumber({int length = 4}) {
    if (this.length <= length) return this;
    return '*' * (this.length - length) + substring(this.length - length);
  }
}
