import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Sử dụng Vân tay để mở khóa Safe City',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } catch (e) {
      if (kDebugMode) {
        print('Biometric authentication error: $e');
      }
      return false;
    }
  }
}
