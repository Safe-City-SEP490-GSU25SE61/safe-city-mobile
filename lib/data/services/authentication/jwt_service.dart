import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenService {
  final secureStorage = const FlutterSecureStorage();
  final http.Client client = http.Client();

  Future<bool> isTokenExpired(String? token) async {
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

  Future<bool> isRefreshTokenExpired(String? token) async {
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

// Future<void> refreshAccessToken() async {
//   final refreshToken = await secureStorage.read(key: 'refresh_token');
//
//   if (await isRefreshTokenExpired(refreshToken)) {
//     await secureStorage.deleteAll();
//     Get.offAll(() => const LoginScreen());
//     return;
//   }
//
//   try {
//     var response = await client.post(
//       Uri.parse('${TConnectionStrings.deployment}auth/refresh-token'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({"refresh_token": refreshToken}),
//     ).timeout(const Duration(seconds: 10));
//
//     var responseData = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       await secureStorage.write(key: 'access_token', value: responseData['access_token']);
//     } else if (response.statusCode == 401 && responseData['message'] == 'JWT token has expired and revoked') {
//       await secureStorage.deleteAll();
//       Get.offAll(() => const LoginScreen());
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('Failed to refresh token: $e');
//     }
//   }
// }

// Future<http.Response> performApiRequest({
//   required Uri uri,
//   Map<String, String>? headers,
//   Object? body,
//   bool refreshTokenOnFailure = true,
// }) async {
//   var response = await client.post(uri, headers: headers, body: body);
//
//   if (response.statusCode == 401 && refreshTokenOnFailure) {
//     await refreshAccessToken();
//     final newAccessToken = await secureStorage.read(key: 'access_token');
//     headers?['Authorization'] = 'Bearer $newAccessToken';
//     response = await client.post(uri, headers: headers, body: body);
//   }
//
//   return response;
// }
}
