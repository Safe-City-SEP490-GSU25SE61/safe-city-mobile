// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../../../features/personalization/models/user_profile_model.dart';
// import '../../../utils/constants/connection_strings.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class UserProfileService {
//   var client = http.Client();
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//
//   Future<String?> getAccessToken() async {
//     return await secureStorage.read(key: 'access_token');
//   }
//
//   Future<UserProfileModel?> getUserProfile() async {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) {
//       return null;
//     }
//
//     String? userId = await secureStorage.read(key: 'user_id');
//     if (userId == null) {
//       return null;
//     }
//
//     try {
//       var response = await client.get(
//         Uri.parse('${TConnectionStrings.deployment}setting/account/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       ).timeout(const Duration(seconds: 10));
//
//       if (response.statusCode == 202) {
//         final data = jsonDecode(utf8.decode(response.bodyBytes));
//
//         if (kDebugMode) {
//           print('Successfully retrieved user information: $data');
//         }
//
//         return UserProfileModel.fromJson(data['data']);
//       } else {
//         if (kDebugMode) {
//           print("Failed to retrieve user profile: ${response.body}");
//         }
//         return null;
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error retrieving user profile: $e");
//       }
//       return null;
//     }
//   }
//
//   Future<Map<String, Object>> updateUserProfilePicture(XFile image) async {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) {
//       return {"success": false, "message": "No access token found"};
//     }
//
//     String? userId = await secureStorage.read(key: 'user_id');
//
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             '${TConnectionStrings.deployment}setting/account/upload-image/$userId'),
//       );
//       request.headers['Authorization'] = 'Bearer $accessToken';
//       request.headers['Accept'] = '*/*';
//
//       var file = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//       );
//       request.files.add(file);
//
//       var response = await request.send().timeout(const Duration(seconds: 10));
//       final responseData = await http.Response.fromStream(response);
//
//       if (response.statusCode == 200) {
//         final responseJson = jsonDecode(responseData.body);
//         if (kDebugMode) {
//           print(
//               'Successfully updated profile picture: ${responseJson["data"]["imageUrl"]}');
//         }
//         return {
//           "success": true,
//           "message": "Profile picture updated successfully",
//           "imageUrl": responseJson["data"]["imageUrl"]
//         };
//       } else {
//         final responseJson = jsonDecode(responseData.body);
//         if (kDebugMode) {
//           print('Failed to update profile picture: ${responseJson["message"]}');
//         }
//         return {
//           "success": false,
//           "message": 'Failed to update profile picture',
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error updating profile picture: $e');
//       }
//       return {
//         "success": false,
//         "message": 'Error updating profile picture: $e'
//       };
//     }
//   }
//
//   Future<Map<String, Object>> updateUserProfile(Map<String, dynamic> updatedFields) async {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) {
//       return {"success": false, "message": "No access token found"};
//     }
//
//     String? userId = await secureStorage.read(key: 'user_id');
//
//     try {
//       var response = await client
//           .post(
//               Uri.parse(
//                   '${TConnectionStrings.deployment}setting/account/update/$userId'),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $accessToken'
//               },
//               body: jsonEncode(updatedFields))
//           .timeout(const Duration(seconds: 10));
//
//       if (response.statusCode == 200) {
//         if (kDebugMode) {
//           print('Successfully updated user profile');
//         }
//         return {
//           "success": true,
//           "message": "User profile updated successfully"
//         };
//       } else if (response.statusCode == 404) {
//         if (kDebugMode) {
//           print('User not found: ${response.body}');
//         }
//         return {
//           "success": false,
//           "message": "User not found",
//         };
//       } else {
//         if (kDebugMode) {
//           print('Failed to update user profile: ${response.body}');
//         }
//         return {
//           "success": false,
//           "message": 'Failed to update user profile',
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error updating user profile: $e');
//       }
//       return {"success": false, "message": 'Error updating user profile: $e'};
//     }
//   }
// }
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../../../features/personalization/models/user_profile_model.dart';
// import '../../../utils/constants/connection_strings.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class UserProfileService {
//   var client = http.Client();
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//
//   Future<String?> getAccessToken() async {
//     return await secureStorage.read(key: 'access_token');
//   }
//
//   Future<UserProfileModel?> getUserProfile() async {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) {
//       return null;
//     }
//
//     String? userId = await secureStorage.read(key: 'user_id');
//     if (userId == null) {
//       return null;
//     }
//
//     try {
//       var response = await client.get(
//         Uri.parse('${TConnectionStrings.deployment}setting/account/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       ).timeout(const Duration(seconds: 10));
//
//       if (response.statusCode == 202) {
//         final data = jsonDecode(utf8.decode(response.bodyBytes));
//
//         if (kDebugMode) {
//           print('Successfully retrieved user information: $data');
//         }
//
//         return UserProfileModel.fromJson(data['data']);
//       } else {
//         if (kDebugMode) {
//           print("Failed to retrieve user profile: ${response.body}");
//         }
//         return null;
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error retrieving user profile: $e");
//       }
//       return null;
//     }
//   }
//
//   Future<Map<String, Object>> updateUserProfilePicture(XFile image) async {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) {
//       return {"success": false, "message": "No access token found"};
//     }
//
//     String? userId = await secureStorage.read(key: 'user_id');
//
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             '${TConnectionStrings.deployment}setting/account/upload-image/$userId'),
//       );
//       request.headers['Authorization'] = 'Bearer $accessToken';
//       request.headers['Accept'] = '*/*';
//
//       var file = await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//       );
//       request.files.add(file);
//
//       var response = await request.send().timeout(const Duration(seconds: 10));
//       final responseData = await http.Response.fromStream(response);
//
//       if (response.statusCode == 200) {
//         final responseJson = jsonDecode(responseData.body);
//         if (kDebugMode) {
//           print(
//               'Successfully updated profile picture: ${responseJson["data"]["imageUrl"]}');
//         }
//         return {
//           "success": true,
//           "message": "Profile picture updated successfully",
//           "imageUrl": responseJson["data"]["imageUrl"]
//         };
//       } else {
//         final responseJson = jsonDecode(responseData.body);
//         if (kDebugMode) {
//           print('Failed to update profile picture: ${responseJson["message"]}');
//         }
//         return {
//           "success": false,
//           "message": 'Failed to update profile picture',
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error updating profile picture: $e');
//       }
//       return {
//         "success": false,
//         "message": 'Error updating profile picture: $e'
//       };
//     }
//   }
//
//   Future<Map<String, Object>> updateUserProfile(Map<String, dynamic> updatedFields) async {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) {
//       return {"success": false, "message": "No access token found"};
//     }
//
//     String? userId = await secureStorage.read(key: 'user_id');
//
//     try {
//       var response = await client
//           .post(
//               Uri.parse(
//                   '${TConnectionStrings.deployment}setting/account/update/$userId'),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $accessToken'
//               },
//               body: jsonEncode(updatedFields))
//           .timeout(const Duration(seconds: 10));
//
//       if (response.statusCode == 200) {
//         if (kDebugMode) {
//           print('Successfully updated user profile');
//         }
//         return {
//           "success": true,
//           "message": "User profile updated successfully"
//         };
//       } else if (response.statusCode == 404) {
//         if (kDebugMode) {
//           print('User not found: ${response.body}');
//         }
//         return {
//           "success": false,
//           "message": "User not found",
//         };
//       } else {
//         if (kDebugMode) {
//           print('Failed to update user profile: ${response.body}');
//         }
//         return {
//           "success": false,
//           "message": 'Failed to update user profile',
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error updating user profile: $e');
//       }
//       return {"success": false, "message": 'Error updating user profile: $e'};
//     }
//   }
// }
