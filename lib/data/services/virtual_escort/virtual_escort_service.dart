import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../features/virtual_escort/models/virtual_escort_group_detail.dart';
import '../../../features/virtual_escort/models/virtual_escort_pending_request.dart';

class VirtualEscortService {
  var client = http.Client();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>> createEscortGroup(String name) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiConnection}escort-groups'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = '*/*';
      request.fields['Name'] = name;

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print(
          "Create Escort Group response: ${response.statusCode} -> ${response.body}",
        );
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "message": jsonData["message"] ?? "Group created successfully",
          "data": jsonData["data"],
        };
      } else {
        final jsonData = jsonDecode(response.body);
        return {
          "success": false,
          "message": jsonData["message"] ?? "Failed to create group",
          "errors": jsonData["errors"] ?? {},
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating escort group: $e");
      }
      return {"success": false, "message": "Exception occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> getMyEscortGroups() async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final response = await client.get(
        Uri.parse('${apiConnection}escort-groups/my-groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print(
          "Get My Escort Groups response: ${response.statusCode} -> ${response.body}",
        );
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "message": jsonData["message"] ?? "Data fetched successfully",
          "data": jsonData["data"] ?? [],
        };
      } else {
        final jsonData = jsonDecode(response.body);
        return {
          "success": false,
          "message": jsonData["message"] ?? "Failed to fetch groups",
          "errors": jsonData["errors"] ?? {},
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching escort groups: $e");
      }
      return {"success": false, "message": "Exception occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> getEscortGroupDetail(int groupId) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final response = await client.get(
        Uri.parse('${apiConnection}escort-groups/$groupId/waiting-room'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print("Get Escort Group Detail: ${response.statusCode} -> ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "data": VirtualEscortGroupDetail.fromJson(jsonData["data"]),
        };
      } else {
        final jsonData = jsonDecode(response.body);
        return {
          "success": false,
          "message": jsonData["message"] ?? "Failed to fetch group detail",
        };
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching group detail: $e");
      return {"success": false, "message": "Exception: $e"};
    }
  }

  Future<Map<String, dynamic>> deleteEscortGroup(String groupCode) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final uri = Uri.parse('${apiConnection}escort-groups?groupCode=$groupCode');

      final response = await client.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Delete Escort Group response: ${response.statusCode} -> ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "message": jsonData["message"] ?? "Group deleted successfully",
        };
      } else {
        final jsonData = jsonDecode(response.body);
        return {
          "success": false,
          "message": jsonData["message"] ?? "Failed to delete group",
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting escort group: $e");
      }
      return {"success": false, "message": "Exception occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> joinEscortGroupByCode(String code) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final uri = Uri.parse('${apiConnection}escort-groups/join-code?code=$code');

      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Join Escort Group response: ${response.statusCode} -> ${response.body}");
      }

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": jsonData["message"] ?? "Gửi yêu cầu tham gia nhóm thành công.",
          "data": jsonData["data"]
        };
      } else if (response.statusCode == 400) {
        if (kDebugMode) {
          print("400 Response Body: ${response.body}");
        }
        final message = jsonData["message"];
        if (message == "Bạn đã gửi yêu cầu tham gia nhóm này.") {
          return {
            "success": false,
            "message": "Bạn đã gửi yêu cầu tham gia nhóm này."
          };
        }
        return {
          "success": false,
          "message": message ?? "Lỗi xác thực",
          "errors": jsonData["errors"] ?? {}
        };
      } else {
        return {
          "success": false,
          "message": jsonData["message"] ?? "Không thể tham gia nhóm",
          "errors": jsonData["errors"] ?? {}
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error joining escort group: $e");
      }
      return {"success": false, "message": "Đã xảy ra lỗi vui lòng thử lại sau: $e"};
    }
  }

  Future<Map<String, dynamic>> getPendingRequests(int groupId) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final response = await client.get(
        Uri.parse('${apiConnection}escort-groups/$groupId/pending-requests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Pending Requests: ${response.statusCode} -> ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "data": (jsonData["data"] as List)
              .map((e) => VirtualEscortPendingRequest.fromJson(e))
              .toList(),
        };
      } else {
        final jsonData = jsonDecode(response.body);
        return {"success": false, "message": jsonData["message"] ?? "Failed"};
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching pending requests: $e");
      return {"success": false, "message": "Exception: $e"};
    }
  }

  Future<Map<String, dynamic>> verifyMemberRequest({required int groupId, required int requestId, required bool approve,}) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final uri = Uri.parse(
          '${apiConnection}escort-groups/review-request?requestId=$requestId&approve=$approve'
      );
      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Verify Member Request: ${response.statusCode} -> ${response.body}");
      }

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": jsonData["message"] ?? "Request verified successfully",
        };
      } else if (response.statusCode == 400) {
        return {
          "success": false,
          "message": jsonData["message"] ?? "Invalid request",
          "errors": jsonData["errors"] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": jsonData["message"] ?? "Failed to verify request",
          "errors": jsonData["errors"] ?? {},
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error verifying member request: $e");
      }
      return {"success": false, "message": "Exception occurred: $e"};
    }
  }
}
