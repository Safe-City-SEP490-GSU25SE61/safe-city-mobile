import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

import '../../../features/virtual_escort/models/virtual_escort_group_detail.dart';
import '../../../features/virtual_escort/models/virtual_escort_pending_request.dart';
import '../../../features/virtual_escort/models/virtual_escort_personal_history.dart';

class VirtualEscortService {
  var client = http.Client();
  HubConnection? hubConnection;
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final leaderLat = 0.0.obs;
  final leaderLng = 0.0.obs;

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<String?> getMemberId() async {
    return await secureStorage.read(key: 'member_id');
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
          "Create Escort Group response: ${response.statusCode} -> ${response
              .body}",
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
          "Get My Escort Groups response: ${response.statusCode} -> ${response
              .body}",
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
        print("Get Escort Group Detail: ${response.statusCode} -> ${response
            .body}");
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
      final uri = Uri.parse(
          '${apiConnection}escort-groups?groupCode=$groupCode');

      final response = await client.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print(
            "Delete Escort Group response: ${response.statusCode} -> ${response
                .body}");
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
      final uri = Uri.parse(
          '${apiConnection}escort-groups/join-code?code=$code');

      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Join Escort Group response: ${response.statusCode} -> ${response
            .body}");
      }

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": jsonData["message"] ??
              "Gửi yêu cầu tham gia nhóm thành công.",
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
      return {
        "success": false,
        "message": "Đã xảy ra lỗi vui lòng thử lại sau: $e"
      };
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
        print(
            "Get Pending Requests: ${response.statusCode} -> ${response.body}");
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

  Future<Map<String, dynamic>> verifyMemberRequest(
      {required int groupId, required int requestId, required bool approve,}) async {
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
        print("Verify Member Request: ${response.statusCode} -> ${response
            .body}");
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

  Future<Map<String, dynamic>> deleteMember(int memberId) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }
    try {
      final uri = Uri.parse(
          '${apiConnection}escort-groups/member?memberId=$memberId');
      final response = await client.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));
      if (kDebugMode) {
        print("Delete Member: ${response.statusCode} -> ${response.body}");
      }
      final jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": jsonData["message"] ?? "Member removed successfully"
        };
      } else {
        return {
          "success": false,
          "message": jsonData["error"] ?? jsonData["message"] ?? "Failed"
        };
      }
    } catch (e) {
      if (kDebugMode) print("Error deleting member: $e");
      return {"success": false, "message": "Exception: $e"};
    }
  }

  Future<Map<String, dynamic>> updateGroupSettings(
      {required String groupCode, required bool autoApprove, required bool receiveRequest}) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final uri = Uri.parse('${apiConnection}escort-groups/settings');
      final response = await client.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "groupCode": groupCode,
          "autoApprove": autoApprove,
          "receiveRequest": receiveRequest,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Update Group Settings: ${response.statusCode} -> ${response
            .body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "message": jsonData["message"] ?? "Update settings successfully",
        };
      } else {
        final jsonData = jsonDecode(response.body);
        return {
          "success": false,
          "message": jsonData["error"] ?? jsonData["message"] ??
              "Failed to update settings",
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating group settings: $e");
      }
      return {"success": false, "message": "Exception: $e"};
    }
  }

  Future<Map<String, dynamic>> getEscortHistory() async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      final response = await client.get(
        Uri.parse('${apiConnection}virtual-escorts/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print("Get Escort History: ${response.statusCode} -> ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          "success": true,
          "data": VirtualEscortPersonalHistory.fromJson(jsonData),
        };
      } else {
        try {
          final jsonData = jsonDecode(response.body);
          return {
            "success": false,
            "message": jsonData["message"] ?? "Failed to fetch history",
          };
        } catch (_) {
          return {
            "success": false,
            "message": response.body.isNotEmpty
                ? response.body
                : "Failed to fetch history",
          };
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching escort history: $e");
      return {"success": false, "message": "Exception: $e"};
    }
  }

  Future<void> initSignalR({required bool isLeader,required int memberId}) async {
    try {
      final token = await getAccessToken();

      if (token == null) {
        debugPrint("❌ Cannot init SignalR: Missing token or memberId");
        return;
      }

      final role = isLeader ? "leader" : "observers";
      final hubUrl = "https://safe-city-back-end.onrender.com/journey-hub?role=$role&memberId=$memberId";

      debugPrint("🔌 Connecting to: $hubUrl");

      hubConnection = HubConnectionBuilder()
          .withUrl(
        hubUrl,
        options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ),
      ).withAutomaticReconnect().build();

      await hubConnection?.start();
      debugPrint("✅ SignalR connected as $role with memberId=$memberId");
    } catch (e) {
      debugPrint("❌ SignalR init failed: $e");
    }
  }

  Future<void> joinGroupSignalR(String groupId) async {
    await hubConnection?.invoke("JoinGroup", args: [groupId]);
  }

  Future<void> updateLocationSignalR(double lat, double lng) async {
    if (hubConnection?.state == HubConnectionState.Connected) {
      try {

        final battery = Battery();
        final batteryLevel = await battery.batteryLevel;
        final isBatteryLow = batteryLevel <= 20;
        final gpsStatus = await geo.Geolocator.isLocationServiceEnabled();
        final isGPSAvailable = gpsStatus;

        final connectivity = await Connectivity().checkConnectivity();
        final isInternetAvailable = connectivity != ConnectivityResult.none;

        await hubConnection?.invoke("SendLocation", args: [
          lat,
          lng,
          isGPSAvailable,
          isInternetAvailable,
          isBatteryLow
        ]);
        debugPrint("📡 Location sent: $lat, $lng");
      } catch (e) {
        debugPrint("❌ Failed to send location (invoke error): $e");
      }
    } else {
      debugPrint("⚠️ Hub not connected, skipping location update.");
    }
  }

  Future<void> stopSignalR() async {
    await hubConnection?.stop();
  }

  Future<Map<String, dynamic>?> getJourneyForObserver(int memberId) async {
    try {
      final token = await getAccessToken();
      final url = Uri.parse(
          "${apiConnection}virtual-escorts/journey-for-observer?memberId=$memberId");

      final response = await http.get(
        url,
        headers: {
          "accept": "*/*",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("❌ Failed to load observer journey: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception in getJourneyForObserver: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> createVirtualEscort({
    required int groupId,
    required String rawJson,
    String vehicle = "bike",
    List<int> watcherIds = const [],
  }) async {
    final token = await getAccessToken();
    if (token == null) {
      return {"success": false, "message": "No access token found"};
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiConnection}virtual-escorts'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = '*/*';

      request.fields['GroupId'] = groupId.toString();
      request.fields['RawJson'] = rawJson;
      request.fields['Vehicle'] = vehicle;
      request.fields['WatcherIds'] = watcherIds.isNotEmpty ? watcherIds.join(',') : "0";

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("Create Virtual Escort: ${response.statusCode} -> ${response.body}");
      }

      final jsonData = (() {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          debugPrint("⚠️ JSON parsing failed: $e");
          return {};
        }
      })();

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": jsonData["message"] ?? "Escort created successfully",
          "data": jsonData["data"]
        };
      } else {
        return {
          "success": false,
          "message": jsonData["message"] ?? "Failed to create escort",
          "errors": jsonData["errors"] ?? {}
        };
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error creating escort: $e");
      return {"success": false, "message": "Exception: $e"};
    }
  }
}