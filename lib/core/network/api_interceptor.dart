import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('────────────────────────────────────────────');
    print('📤 [API REQUEST]');
    print('→ URL: ${options.uri}');
    print('→ METHOD: ${options.method}');
    print('→ HEADERS: ${options.headers}');
    if (options.data != null) {
      print('→ BODY: ${options.data}');
    }
    print('────────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('📥 [API RESPONSE]');
    print('← URL: ${response.requestOptions.uri}');
    print('← STATUS: ${response.statusCode}');
    print('← DATA: ${response.data}');
    print('────────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('⛔ [API ERROR]');
    print('URL: ${err.requestOptions.uri}');
    print('METHOD: ${err.requestOptions.method}');
    if (err.requestOptions.data != null) {
      print('BODY: ${err.requestOptions.data}');
    }
    print('STATUS CODE: ${err.response?.statusCode}');
    print('MESSAGE: ${err.message}');
    if (err.response != null) {
      print('RESPONSE DATA: ${err.response?.data}');
    }
    print('────────────────────────────────────────────');
    super.onError(err, handler);
  }
}
