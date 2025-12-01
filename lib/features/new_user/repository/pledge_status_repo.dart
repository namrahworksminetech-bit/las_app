import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
  
  final ApiClient _apiClient;

  final AppStateProvider appState = GetIt.instance<AppStateProvider>();

  PledgeStatusRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? GetIt.instance<ApiClient>();

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
    String? type,
    required String authToken,
  }) async {
    
    try {
      debugPrint('📡 checkPledgeMfStatus calling POST /customer/pledge-mf with reqId=$reqId');

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
        if (respData is Map && respData['message'] != null) serverMessage = respData['message'].toString();
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
          'Failed to check pledge status (HTTP ${statusCode ?? "null"}). ${serverMessage ?? ""}');
    } on DioException catch (e) {
      debugPrint('⛔ DioException in checkPledgeMfStatus: type=${e.type}, response=${e.response?.data}');
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error occurred.';
      return Failure(msg);
    } catch (e, st) {
      debugPrint('⛔ Unexpected error in checkPledgeMfStatus: $e\n$st');
      return Failure('Error: $e');
    }
  }



}
