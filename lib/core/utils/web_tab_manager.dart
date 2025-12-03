import 'package:universal_html/html.dart' as html;

class WebTabManager {
  static html.WindowBase? _webViewWindow;

  /// Store reference when WebViewScreen opens window
  static void setWebViewWindow(html.WindowBase window) {
    _webViewWindow = window;
  }

  /// Close WebView window on completed status
  static void closeWebViewWindow() {
    if (_webViewWindow != null && !_webViewWindow!.closed!) {
      _webViewWindow!.close();
      _webViewWindow = null;
    }
  }
}
