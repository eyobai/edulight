import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatelessWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onWebViewCreated: (InAppWebViewController controller) {
          // You can store the controller if needed
        },
        onLoadError: (InAppWebViewController controller, Uri? url, int code,
            String message) {
          // Handle load error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load URL: $message')),
          );
        },
      ),
    );
  }
}
