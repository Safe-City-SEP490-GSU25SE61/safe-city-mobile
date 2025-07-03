import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/widgets/appbar/appbar.dart';

class SubscriptionWebViewPayment extends StatefulWidget {
  final String url;

  const SubscriptionWebViewPayment({super.key, required this.url});

  @override
  State<SubscriptionWebViewPayment> createState() =>
      _SubscriptionWebViewPaymentScreenState();
}

class _SubscriptionWebViewPaymentScreenState
    extends State<SubscriptionWebViewPayment> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Gói đăng ký'),
        showCloseButton: false,
        showBackArrow: true,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
