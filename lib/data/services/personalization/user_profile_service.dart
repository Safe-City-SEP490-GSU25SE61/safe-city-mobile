import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../features/personalization/models/achivement_model.dart';
import '../../../features/personalization/models/pont_history_model.dart';
import '../../../features/personalization/models/user_profile_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileService {
  var client = http.Client();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final secureStorage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<UserProfileModel?> getUserProfile() async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      return null;
    }

    try {
      var response = await client.get(
        Uri.parse('${apiConnection}settings/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 202) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (kDebugMode) {
          print('Successfully retrieved user information: $data');
        }

        final profile = UserProfileModel.fromJson(data['data']);
        final isBiometric = data['data']['isBiometricEnabled'] ?? false;
        await secureStorage.write(
          key: 'isBiometricLoginEnabled',
          value: isBiometric.toString(),
        );
        return profile;
      } else {
        if (kDebugMode) {
          print("Failed to retrieve user profile: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error retrieving user profile: $e");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final token = await getAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'No token found'};
    }

    final response = await client.put(
      Uri.parse('${apiConnection}settings/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Password changed successfully.'};
    } else {
      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Unknown error',
        'errors': body['errors'] ?? {},
      };
    }
  }

  Future<Map<String, Object>> updateUserProfilePicture(XFile image) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiConnection}settings/profile/avatar'),
      );
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Accept'] = '*/*';

      var file = await http.MultipartFile.fromPath('file', image.path);
      request.files.add(file);

      var response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(responseData.body);
        if (kDebugMode) {
          print(
            'Successfully updated profile picture: ${responseJson["message"]}',
          );
        }
        return {
          "success": true,
          "message":
              responseJson["message"] ?? "Profile picture updated successfully",
        };
      } else {
        final responseJson = jsonDecode(responseData.body);
        if (kDebugMode) {
          print('Failed to update profile picture: ${responseJson["message"]}');
        }
        return {
          "success": false,
          "message":
              responseJson["message"] ?? "Failed to update profile picture",
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile picture: $e');
      }
      return {
        "success": false,
        "message": 'Error updating profile picture: $e',
      };
    }
  }

  Future<Map<String, Object>> updateUserProfile({
    required String deviceId,
    required bool isBiometricEnabled,
    required String email,
    required String phone,
    File? frontImage,
    File? backImage,
  }) async {
    final String? accessToken = await getAccessToken();
    if (accessToken == null) {
      return {"success": false, "message": "No access token found"};
    }

    final uri = Uri.parse('${apiConnection}settings/profile/biometric');

    final request = http.MultipartRequest('PUT', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
      'accept': '*/*',
    });

    request.fields['deviceId'] = deviceId;
    request.fields['isBiometricEnabled'] = isBiometricEnabled.toString();
    request.fields['email'] = email;
    request.fields['phone'] = phone;

    if (frontImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('frontImage', frontImage.path),
      );
    }

    if (backImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('backImage', backImage.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print(
          "Update profile response: ${response.statusCode} -> ${response.body}",
        );
      }

      final jsonBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": jsonBody["message"] ?? "Successfully updated profile",
        };
      } else if (response.statusCode == 400) {
        return {
          "success": false,
          "message": jsonBody["message"] ?? "Validation Error",
          "errors": jsonBody["errors"] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": "Unexpected error occurred",
          "statusCode": response.statusCode,
          "body": jsonBody,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating profile: $e");
      }
      return {"success": false, "message": "Exception occurred: $e"};
    }
  }

  Future<List<AchievementModel>> fetchAchievements(String accessToken) async {
    final uri = Uri.parse('${apiConnection}achievement/config');

    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'] ?? [];

      return data.map((json) => AchievementModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load achievements');
    }
  }

  Future<PointHistoryModel?> fetchPointHistory({
    String range = "month",
    String? sourceType,
    bool desc = true,
  }) async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final uri = Uri.parse(
        '${apiConnection}points/history?range=$range&desc=$desc'
        '${sourceType != null ? "&sourceType=$sourceType" : ""}',
      );

      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));

        return PointHistoryModel.fromJson(jsonBody['data']);
      } else {
        if (kDebugMode) {
          print("Failed to fetch point history: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching point history: $e");
      }
      return null;
    }
  }
}
