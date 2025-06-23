import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPasswordService {
  var client = http.Client();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];

  Future<Map<String, dynamic>> sendForgotPasswordEmail(String email) async {
    final uri = Uri.parse('${apiConnection}auth/forgot-password');

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim()}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Đã xảy ra lỗi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Đã xảy ra lỗi: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String activationCode,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${apiConnection}auth/reset-password');

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'activationCode': activationCode.trim(),
          'newPassword': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else if (response.statusCode == 400 && responseData['errors'] != null) {
        return {
          'success': false,
          'validationError': true,
          'errors': responseData['errors'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Lỗi không xác định',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }
}
