import 'package:flutter/foundation.dart';

class AppStateProvider extends ChangeNotifier {
  String? _token;
  String? _reqId;
  String? _name;
  String? _lenderCode;

  String? get token => _token;
  String? get reqId => _reqId;
  String? get name => _name;
  String? get lenderCode => _lenderCode;

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

  void clear() {
    _token = null;
    _reqId = null;
    _name = null;
    _lenderCode = null;
    notifyListeners();
  }
}
