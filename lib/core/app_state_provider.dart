import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


  void setEmail(String email) async {
    print("📩 Saving Email to AppState + SharedPrefs: $email");

    _email = email;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
  }
String? _pan;
String? get pan => _pan;

void setPan(String pan) async {
  _pan = pan;
  notifyListeners();
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("pan_number", pan);
}

  // -----------------------------
  // SAVE NAME
  // -----------------------------
  void setName(String name) async {
    print("👤 Saving Name to AppState + SharedPrefs: $name");

    _name = name;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
  }


  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setReqId(String reqId) {
    _reqId = reqId;
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
