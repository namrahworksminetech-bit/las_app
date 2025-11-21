import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/results/result.dart';
import '../../../core/network/api_client.dart';

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

  Future<void> connect(String token) async {
    try {
      print(
        '🔗 Connecting to WebSocket with token: ${token.substring(0, 10)}...',
      );
      final uri = Uri.parse(
        'wss://socket-dev.valuenable.in?token=$token&module=las',
      );
      print('🔗 WebSocket URI: $uri');

      _channel = WebSocketChannel.connect(uri);
      _controller = StreamController<Map<String, dynamic>>.broadcast();

      _channel!.stream.listen(
        (data) {
          print('📡 Raw WebSocket data received: $data');
          try {
            final response = json.decode(data) as Map<String, dynamic>;
            print('📝 Decoded WebSocket data: $response');
            _controller?.add(response);
          } catch (e) {
            print('❌ WebSocket decode error: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
        },
      );

      // Wait for connection to be ready
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ WebSocket connection established successfully');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _statusTimer?.cancel();
  }
}

class PledgeStatusRepository {
  final ApiClient? _apiClient;

  PledgeStatusRepository([this._apiClient]);

  Stream<Map<String, dynamic>> listenForKycStatus() {
    return WebSocketService.instance.stream ?? const Stream.empty();
  }

  Future<void> connectWebSocket(String token) async {
    await WebSocketService.instance.connect(token);
  }

  void disconnectWebSocket() {
    WebSocketService.instance.disconnect();
  }

  Future<Result<Map<String, dynamic>>> checkSocketStatus({
    required String reqId,
    required String authToken,
  }) async {
    try {
      print('🚀 Starting checkPledgeStatus with reqId: $reqId');
      await WebSocketService.instance.connect(authToken);

      final completer = Completer<Result<Map<String, dynamic>>>();
      StreamSubscription? subscription;

      subscription = WebSocketService.instance.stream?.listen((response) {
        print('📨 Received WebSocket response: $response');
        print('🔍 Response type: ${response.runtimeType}');
        print('🔍 Response keys: ${response.keys}');

        subscription?.cancel();
        completer.complete(Success(response));
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          subscription?.cancel();
          return const Failure('Request timeout');
        },
      );
    } catch (e) {
      return Failure('Error: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> checkPledgeMfStatus({
    required String reqId,
    required String authToken,
  }) async {
    if (_apiClient == null) {
      return const Failure('API client not initialized');
    }

    try {
      final response = await _apiClient!.post(
        '/customer/pledge-mf',
        data: {'req_id': reqId, 'type': 'pledge'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(response.data);
      } else {
        return Failure('Failed to check pledge status');
      }
    } on DioException catch (e) {
      print("⏰ Dio timeout or error: ${e.type}");
      final msg =
          e.response?.data?['message'] ??
          e.message ??
          'Network error occurred.';
      return Failure(msg);
    } catch (e) {
      return Failure('Error: $e');
    }
  }
}
