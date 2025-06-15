import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  factory TokenManager() => _instance;

  TokenManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> refreshTokenIfNeeded() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final encodedRefreshToken = base64Encode(utf8.encode(refreshToken));

      final response = await _client
          .post(
            Uri.parse('${apiConnection}auth/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': encodedRefreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
