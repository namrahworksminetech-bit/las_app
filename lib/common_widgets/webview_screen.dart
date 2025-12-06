import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/injection_container.dart';
import '../core/network/api_client.dart';
import '../core/utils/web_tab_manager.dart';
import '../features/new_user/bloc/eligibility_bloc.dart';
import 'package:universal_html/html.dart' as html;

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;
  final VoidCallback? onKycComplete;
  final EligibilityBloc? bloc;

  const WebViewScreen({
    Key? key,
    required this.url,
    this.title,
    this.onKycComplete,
    this.bloc,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  Timer? _pollTimer;
  final ApiClient _apiClient = getIt<ApiClient>();
  static const platform = MethodChannel('webview_permissions');
  StreamSubscription? _closeSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to bloc's close stream
    if (widget.bloc != null) {
      _closeSubscription = widget.bloc!.webViewCloseStream.listen((_) {
        debugPrint('🚪 WebView closing - signal from bloc');
        if (mounted) Get.back();
      });
    }

    // For web platform, open URL in new tab and close current screen
    if (kIsWeb) {
      _openUrlInNewTab(widget.url);
      return;
    }

    _requestPermissions();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print('🌐 WebView URL: ${request.url}');

            // Check if KYC is completed based on redirect URL
            if (request.url.contains('account-verification-complete')) {
              print('✅ KYC completed detected from URL: ${request.url}');
              widget.onKycComplete?.call();
            }

            // Prevent opening new tabs, keep it in the same WebView
            if (request.url.startsWith("https")) {
              controller.loadRequest(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Enable camera permissions for Android WebView
    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller.loadRequest(Uri.parse(widget.url));
  }

  void _openUrlInNewTab(String url) async {
    if (kIsWeb) {
      // Store window reference for closing later
      final newWindow = html.window.open(
        url,
        '_blank',
        'width=1200,height=800,scrollbars=yes,resizable=yes',
      );

      // Store reference in WebTabManager
      if (newWindow != null) {
        WebTabManager.setWebViewWindow(newWindow);
      }
      // Future.delayed(Duration(seconds: 20)).then((value) {
      //   WebTabManager.closeWebViewWindow();
      //   print("auto_close---------------");
      // });
      Get.back();
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();

    // Enable WebView permissions via platform channel
    try {
      await platform.invokeMethod('enableWebViewPermissions');
    } catch (e) {
      print('Failed to enable WebView permissions: $e');
    }
  }

  void _startPolling() {
    // API call handled in digio_repo
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _closeSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // For web platform, show loading screen while opening URL
    if (kIsWeb) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final content = WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              Image.asset(
                'assets/images/sliQ.png',
                height: 28, // Adjust size as needed
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title ?? 'WebView',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            // if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
    
    return content;
  }
}
