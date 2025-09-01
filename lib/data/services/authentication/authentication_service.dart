import 'dart:convert';
import 'dart:io';
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
    required String idNumber,
    required String issueDate,
    required String expiryDate,
    required String placeOfIssue,
    required String placeOfBirth,
    required String address,
    required File frontImage,
    required File backImage,
  }) async {
    final uri = Uri.parse('${apiConnection}auth/register');
    final request = http.MultipartRequest('POST', uri);

    try {
      request.fields['fullName'] = fullName.trim();
      request.fields['email'] = email.trim();
      request.fields['phone'] = phone.trim();
      request.fields['password'] = password.trim();
      request.fields['dateOfBirth'] = dateOfBirth;
      request.fields['gender'] = gender.toString();
      request.fields['idNumber'] = idNumber;
      request.fields['issueDate'] = issueDate;
      request.fields['expiryDate'] = expiryDate;
      request.fields['placeOfIssue'] = placeOfIssue;
      request.fields['placeOfBirth'] = placeOfBirth;
      request.fields['address'] = address;

      request.files.add(
        await http.MultipartFile.fromPath('frontImage', frontImage.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('backImage', backImage.path),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 10),
      );
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 202) {
        if (kDebugMode) {
          print('Successful Registration: $responseData');
        }
        return {"success": true, "data": responseData};
      } else if (response.statusCode == 400) {
        if (kDebugMode) {
          print('Validation Error: $responseBody');
        }
        return {
          "success": false,
          "validationError": true,
          "message": responseData['message'],
          "errors": responseData['errors'],
        };
      } else if (response.statusCode == 409) {
        if (kDebugMode) {
          print('Register failed: $responseBody');
        }
        return {
          "success": false,
          "message":
              'Tài khoản này đã được đăng kí với email này, vui lòng kiểm tra lại',
        };
      } else if (response.statusCode == 500) {
        if (kDebugMode) {
          print('Server Error (${response.statusCode}): $responseBody');
        }
        final backendMessage = responseData['message'];
        return {"success": false, "message": backendMessage};
      } else {
        if (kDebugMode) {
          print('Unexpected Response Code: ${response.statusCode}');
          print('Unexpected Response Body: $responseBody');
        }
        return {
          "success": false,
          "message": 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Register failed: $e');
      }
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

  Future<Map<String, dynamic>> handleBiometricLogin({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      final uri = Uri.parse('${apiConnection}auth/biometric-login');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
          "deviceId": deviceId,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: $responseData');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Successful Login: $responseData');
        }
        return {"success": true, "data": responseData};
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "unauthorized": true,
          "message": responseData['message'],
        };
      } else {
        return {
          "success": false,
          "message": responseData['message'] ?? 'Lỗi không xác định',
        };
      }
    } catch (e) {
      return {"success": false, "message": 'Lỗi hệ thống: $e'};
    }
  }
}
