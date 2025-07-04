import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../features/authentication/screens/login/login.dart';
import '../../features/personalization/screens/subscription/subscription_payment_cancel.dart';
import '../../features/personalization/screens/subscription/subscription_payment_success.dart';

class AppLinkHandler {
  static final AppLinkHandler _instance = AppLinkHandler._internal();

  factory AppLinkHandler() => _instance;

  AppLinkHandler._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      _sub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleUri(uri);
        },
        onError: (err) {
          if (kDebugMode) print('AppLinks error: $err');
        },
      );
    } catch (e) {
      if (kDebugMode) print("AppLinks init exception: $e");
    }
  }

  void _handleUri(Uri uri) {
    if (kDebugMode) print('App link received: $uri');

    final isSuccessPayment =
        uri.scheme == 'safe-city' && uri.host == 'payment-success';

    final isCancelPayment =
        uri.scheme == 'safe-city' && uri.host == 'payment-cancel';

    if (isSuccessPayment) {
      Get.offAll(() => const PaymentSuccessScreen());
    } else if (isCancelPayment) {
      Get.offAll(() => const PaymentCancelScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  void dispose() => _sub?.cancel();
}
