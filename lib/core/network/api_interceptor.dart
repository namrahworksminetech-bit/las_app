import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:las_app/features/login/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
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


//handling 403 error here.
    if (err.response?.statusCode == 403) {
      final data = err.response?.data;

   
      if (data is Map && data['message']?.toString().toLowerCase().contains("expired token") == true) {

        print("TOKEN EXPIRED - Logging out user");


        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
  Get.snackbar(
          "Session Expired",
          "Your session has expired. Please log in again.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
 
        Get.offAll(() => const LoginScreen());

     
        return;
      }
    }

    super.onError(err, handler);
  }
}
