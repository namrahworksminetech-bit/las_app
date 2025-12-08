import 'package:flutter/foundation.dart';

class AppStateProvider extends ChangeNotifier {
  String? _token;

  String? _reqId;
  String? _name;
  String? _lenderCode;
  String? _mobileNumber;

  String? get token => _token;

  String? get reqId => _reqId;
  String? get name => _name;
  String? get lenderCode => _lenderCode;
  String? get mobileNumber => _mobileNumber;
  String? _email;
  String? get email => _email;

  void setEmail(String email) {
     print("📲 AppStateProvider → email saved: $email"); // ← ADD THIS
    _email = email;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setReqId(String reqId) {
    _reqId = reqId;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setLenderCode(String lenderCode) {
    _lenderCode = lenderCode;
    notifyListeners();
  }

  void setMobileNumber(String mobileNumber) {
    print("📲 AppStateProvider → Mobile Saved: $mobileNumber"); // ← ADD THIS

    _mobileNumber = mobileNumber;
    notifyListeners();
  }

  void clear() {
    _token = null;
    _reqId = null;
    _name = null;
    _lenderCode = null;
    _mobileNumber = null;
    notifyListeners();
  }
}
