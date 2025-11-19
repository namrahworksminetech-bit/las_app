import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/injection_container.dart';
import '../core/network/api_client.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({Key? key, required this.url, this.title})
    : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  Timer? _pollTimer;
  final ApiClient _apiClient = getIt<ApiClient>();

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Prevent opening new tabs, keep it in the same WebView
            if (request.url.startsWith("https")) {
              controller.loadRequest(Uri.parse(request.url));
              return NavigationDecision
                  .prevent; // Prevent default navigation (new tab)
            }
            return NavigationDecision.navigate; // Allow navigation if needed
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _startPolling() {
    // API call handled in digio_repo
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'WebView'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          // if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
