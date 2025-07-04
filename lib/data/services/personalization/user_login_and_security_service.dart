import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserLoginAndSecurityService {
  var client = http.Client();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>> changeBiometricSettings({
    required String deviceId,
    required bool isBiometricEnabled,
  }) async {
    final token = await getAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'No access token found'};
    }

    try {
      final response = await client.put(
        Uri.parse('${apiConnection}settings/biometric'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({
          'deviceId': deviceId,
          'isBiometricEnabled': isBiometricEnabled,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
