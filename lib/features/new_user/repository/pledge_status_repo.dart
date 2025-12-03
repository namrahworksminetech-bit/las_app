import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/results/result.dart';
import '../../../core/network/api_client.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();
  WebSocketService._();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _statusTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = false;
  String? _lastToken;
  bool _shouldStayConnected = true;

  Stream<Map<String, dynamic>>? get stream => _controller?.stream;

  Future<void> connect(String token) async {
    print('----------------------');
    print('🔰 STARTING WEBSOCKET CONNECT METHOD');
    print('----------------------');

    _lastToken = token;
    _shouldStayConnected = true;
    
    // Start connectivity monitoring
    _startConnectivityMonitoring();

    try {
      print('🔐 Received Token (first 10 chars): ${token.substring(0, 10)}...');
      print('🔧 Preparing WebSocket URL...');

      final uri = Uri.parse(
        'wss://socket-dev.valuenable.in?token=$token&module=las',
      );

      print('🌐 Final WebSocket URI: $uri');

      print('📡 Creating WebSocketChannel...');
      _channel = WebSocketChannel.connect(uri);

      print('📦 Creating StreamController...');
      _controller ??= StreamController<Map<String, dynamic>>.broadcast();

      print('👂 Setting up socket listeners...');

      _channel!.stream.listen(
        (data) {
          print('Received raw socket data: $data');
          _isConnected = true;

          try {
            final decoded = json.decode(data);
            print(' Decoded JSON: $decoded');

            if (decoded is Map<String, dynamic>) {
              print('📨 Adding decoded JSON to stream...');
              _controller?.add(decoded);
            } else {
              print('⚠️ Decoded data is not Map<String, dynamic>');
            }
          } catch (e) {
            print('❌ Failed to decode JSON: $e');
          }
        },
        onError: (error) {
          print('❌ SOCKET ERROR: $error');
          _isConnected = false;
          _handleReconnection();
        },
        onDone: () {
          print('🔌 WEBSOCKET CLOSED by server / connection ended.');
          _isConnected = false;
          _handleReconnection();
        },
        cancelOnError: false,
      );

      _isConnected = true;
      print('✅ WebSocket connection ready');

      print('🎉 WebSocket CONNECT function completed successfully.');
    } catch (e) {
      print('❌ FINAL CATCH → WebSocket connection failed: $e');
      _isConnected = false;
      _handleReconnection();
      rethrow;
    }

    print('----------------------');
    print('🏁 END OF CONNECT METHOD');
    print('----------------------');
  }

  void disconnect() {
    print('🔌 Disconnecting WebSocket...');
    _shouldStayConnected = false;
    _isConnected = false;
    _channel?.sink.close();
    _controller?.close();
    _controller = null;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _statusTimer?.cancel();
    _connectivitySubscription?.cancel();
    _lastToken = null;
  }

  void disconnectOnScreenExit() {
    print('🚪 Disconnecting WebSocket on screen exit...');
    disconnect();
  }

  void disconnectOnFinalStepComplete() {
    print('✅ Disconnecting WebSocket on final step completion...');
    disconnect();
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
      
      if (hasConnection && !_isConnected && _shouldStayConnected && _lastToken != null) {
        print('🌐 Internet reconnected, attempting WebSocket reconnection...');
        _handleReconnection();
      } else if (!hasConnection) {
        print('📵 Internet disconnected');
        _isConnected = false;
      }
    });
  }

  void _handleReconnection() {
    if (!_shouldStayConnected || _lastToken == null) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_shouldStayConnected && _lastToken != null && !_isConnected) {
        print('🔄 Attempting to reconnect WebSocket...');
        connect(_lastToken!);
      }
    });
  }
}

class PledgeStatusRepository {
  final ApiClient _apiClient;

  final AppStateProvider appState = GetIt.instance<AppStateProvider>();

  PledgeStatusRepository([ApiClient? apiClient])
    : _apiClient = apiClient ?? GetIt.instance<ApiClient>();

  Stream<Map<String, dynamic>> listenForKycStatus() {
    return WebSocketService.instance.stream ?? const Stream.empty();
  }

  Future<void> connectWebSocket(String token) async {
    await WebSocketService.instance.connect(token);
  }

  void disconnectWebSocket() {
    WebSocketService.instance.disconnect();
  }

  void disconnectWebSocketOnScreenExit() {
    WebSocketService.instance.disconnectOnScreenExit();
  }

  void disconnectWebSocketOnFinalStep() {
    WebSocketService.instance.disconnectOnFinalStepComplete();
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

      // No timeout - keep connection alive until manually disconnected
      return await completer.future;
    } catch (e) {
      return Failure('Error: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> checkPledgeMfStatus({
    required String reqId,
    String? type,
    required String authToken,
  }) async {
    try {
      debugPrint(
        '📡 checkPledgeMfStatus calling POST /customer/pledge-mf with reqId=$reqId',
      );

      final response = await _apiClient.post(
        '/customer/pledge-mf',
        data: {'req_id': reqId, 'type': type ?? 'status'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final statusCode = response.statusCode;
      final respData = response.data;

      // If server returned JSON with a message, prefer that
      String? serverMessage;
      try {
        if (respData is Map && respData['message'] != null)
          serverMessage = respData['message'].toString();
      } catch (_) {}

      if (statusCode == 200 || statusCode == 201) {
        return Success(respData as Map<String, dynamic>);
      }

      // Handle cases where statusCode is null but server returned a valid body
      if (statusCode == null && respData is Map<String, dynamic>) {
        // consider it success if payload contains expected fields
        return Success(respData);
      }

      return Failure(
        'Failed to check pledge status (HTTP ${statusCode ?? "null"}). ${serverMessage ?? ""}',
      );
    } on DioException catch (e) {
      debugPrint(
        '⛔ DioException in checkPledgeMfStatus: type=${e.type}, response=${e.response?.data}',
      );
      final msg =
          e.response?.data?['message'] ??
          e.message ??
          'Network error occurred.';
      return Failure(msg);
    } catch (e, st) {
      debugPrint('⛔ Unexpected error in checkPledgeMfStatus: $e\n$st');
      return Failure('Error: $e');
    }
  }
}
