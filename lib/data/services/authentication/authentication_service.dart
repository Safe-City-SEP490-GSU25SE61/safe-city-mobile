import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationService {
  var client = http.Client();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];

  Future<Map<String, dynamic>> handleSignUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String dateOfBirth,
    required bool gender,
  }) async {
    var userRegisterInformation = {
      "fullName": fullName.trim(),
      "email": email.trim(),
      "phone": phone.trim(),
      "password": password.trim(),
      "dateOfBirth": dateOfBirth,
      "gender": gender,
    };

    try {
      var response = await client
          .post(
            Uri.parse('${apiConnection}auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userRegisterInformation),
          )
          .timeout(const Duration(seconds: 10));

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 202) {
        if (kDebugMode) {
          print('Successful Registration: $responseData');
        }
        return {"success": true, "data": responseData};
      } else if (response.statusCode == 400) {
        if (kDebugMode) {
          print('Validation Error: ${response.body}');
        }
        return {
          "success": false,
          "validationError": true,
          "message": responseData['message'],
          "errors": responseData['errors'],
        };
      } else if (response.statusCode == 409) {
        if (kDebugMode) {
          print('Register failed: ${response.body}');
        }
        return {
          "success": false,
          "message":
              'Tài khoản này đã được đăng kí với email này, vui lòng kiểm tra lại',
        };
      } else {
        return {
          "success": false,
          "message": 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
        };
      }
    } catch (e) {
      return {"success": false, "message": 'Đã xảy ra sự cố: $e'};
    }
  }

  Future<dynamic> handleSignIn({
    required String email,
    required String password,
  }) async {
    var userSignInInformation = {
      "email": email.trim().toLowerCase(),
      "password": password.trim(),
    };
    try {
      var response = await client
          .post(
            Uri.parse('${apiConnection}auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userSignInInformation),
          )
          .timeout(const Duration(seconds: 10));

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Successful Login: $responseData');
        }
        return {"success": true, "data": responseData};
      } else if (response.statusCode == 401) {
        if (responseData['message'] ==
            'Incorrect email/password please try again.') {
          if (kDebugMode) {
            print('Login failed: ${response.body}');
          }
          return {"success": false, "data": responseData};
        } else if (responseData['message'] == 'Your account is not verified.') {
          if (kDebugMode) {
            print('Login failed: ${response.body}');
          }
          return {"accountDisabled": true, "data": responseData};
        } else {
          return {
            "loginFailed": true,
            "message": 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
          };
        }
      }
    } catch (e) {
      return {"loginFailed": false, "message": 'Đã xảy ra sự cố: $e'};
    }
  }
}
