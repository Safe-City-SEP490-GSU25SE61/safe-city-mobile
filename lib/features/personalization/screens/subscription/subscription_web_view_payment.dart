import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/features/personalization/screens/subscription/subscription_payment_cancel.dart';
import 'package:safe_city_mobile/features/personalization/screens/subscription/subscription_payment_success.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/handlers/app_link_handler.dart';

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
            final uri = Uri.parse(url);
            if (uri.scheme == 'safe-city' && uri.host == 'payment-success') {
              debugPrint('Intercepted deep link in WebView: $url');
              Get.offAll(() => const PaymentSuccessScreen());
            }

            if (uri.scheme == 'safe-city' && uri.host == 'payment-cancel') {
              debugPrint('User cancelled payment');
              Navigator.pop(context);
              Get.offAll(() => const PaymentCancelScreen());
            }
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
        showBackArrow: false,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
