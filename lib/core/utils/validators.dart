class Validators {
  static String? required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(v) ? null : 'Invalid email';
  }
  static String? phone(String? v) => (v != null && v.length >= 10) ? null : 'Invalid phone';
}
