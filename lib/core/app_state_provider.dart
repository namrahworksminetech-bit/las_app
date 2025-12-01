import 'package:flutter/foundation.dart';

class AppStateProvider extends ChangeNotifier {
  String? _token;
  String? _reqId;
  String? _name;
<<<<<<< HEAD
  String? _lenderCode;
  String? _mobileNumber;
=======
>>>>>>> 9c76ba7 (changes committed)

  String? get token => _token;
  String? get reqId => _reqId;
  String? get name => _name;
<<<<<<< HEAD
  String? get lenderCode => _lenderCode;
  String? get mobileNumber => _mobileNumber;
=======
>>>>>>> 9c76ba7 (changes committed)

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

<<<<<<< HEAD
  void setLenderCode(String lenderCode) {
    _lenderCode = lenderCode;
    notifyListeners();
  }

  void setMobileNumber(String mobileNumber) {
      print("📲 AppStateProvider → Mobile Saved: $mobileNumber"); // ← ADD THIS

    _mobileNumber = mobileNumber;
    notifyListeners();
  }

=======
>>>>>>> 9c76ba7 (changes committed)
  void clear() {
    _token = null;
    _reqId = null;
    _name = null;
<<<<<<< HEAD
    _lenderCode = null;
    _mobileNumber = null;
=======
>>>>>>> 9c76ba7 (changes committed)
    notifyListeners();
  }
}
