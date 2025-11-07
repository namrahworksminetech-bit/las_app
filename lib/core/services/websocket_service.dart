import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();
  WebSocketService._();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  final _storage = const FlutterSecureStorage();
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _statusTimer;
  bool _isConnecting = false;
  bool _isMonitoringKyc = false;

  Stream<Map<String, dynamic>>? get stream => _controller?.stream;

  Future<void> connect() async {
    try {
      final token = await _storage.read(key: 'token');
      print('🔑 Token for WebSocket: ${token?.substring(0, 10)}...');

      if (token == null) {
        print('❌ No token found for WebSocket connection');
        return;
      }

      final uri = Uri.parse(
        'wss://socket-dev.valuenable.in?token=$token&module=las',
      );
      print('🔗 Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);
      _controller = StreamController<Map<String, dynamic>>.broadcast();

      _channel!.stream.listen(
        (data) {
          // print('📡 Raw WebSocket data received: $data');
          try {
            final decoded = jsonDecode(data);
            print('📝 Decoded WebSocket data: $decoded');
            _controller?.add(decoded);
          } catch (e) {
            print('❌ WebSocket decode error: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _controller?.addError(error);
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _controller?.close();
        },
      );

      print('✅ WebSocket connection established successfully');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    print('🔌 Disconnecting WebSocket...');
    stopKycMonitoring();
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
    print('✅ WebSocket disconnected');
  }

  bool get isConnected => _channel != null;

  void startKycMonitoring() {
    if (_isMonitoringKyc) return;

    _isMonitoringKyc = true;
    print(
      '🔄 [${DateTime.now()}] Starting KYC monitoring - checking every 5 seconds',
    );

    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_channel != null) {
        print('🔍 [${DateTime.now()}] Requesting KYC status...');
        try {
          final statusRequest = {
            'type': 'get_kyc_status',
            'action': 'check_steps',
            'timestamp': DateTime.now().toIso8601String(),
          };
          _channel!.sink.add(jsonEncode(statusRequest));
          print('✅ KYC status request sent');
        } catch (e) {
          print('❌ Failed to send KYC status request: $e');
        }
      } else {
        print('❌ WebSocket not connected, stopping KYC monitoring');
        stopKycMonitoring();
      }
    });
  }

  void stopKycMonitoring() {
    if (!_isMonitoringKyc) return;

    _isMonitoringKyc = false;
    _statusTimer?.cancel();
    _statusTimer = null;
    print('⏹️ [${DateTime.now()}] Stopped KYC monitoring');
  }
}
