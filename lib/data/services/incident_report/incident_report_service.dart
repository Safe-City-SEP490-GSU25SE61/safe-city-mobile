import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';
import '../../../features/incident_report/models/incident_report_model.dart';
import '../../../features/incident_report/models/report_history_model.dart';

class IncidentReportService {
  static final _storage = const FlutterSecureStorage();
  static final String apiConnection = dotenv.env['API_DEPLOYMENT_URL']!;

  static Future<Map<String, dynamic>> submitIncidentReport({
    required IncidentReportModel model,
    required List<PlatformFile> images,
    required PlatformFile? video,
  }) async {
    final uri = Uri.parse('${apiConnection}reports');
    final request = http.MultipartRequest('POST', uri);

    try {
      request.fields.addAll(model.toFormFields());

      if (images.isNotEmpty) {
        for (var image in images) {
          final ext = path.extension(image.path!).replaceFirst('.', '').toLowerCase();
          final isImage = ['jpg', 'jpeg', 'png'].contains(ext);

          if (isImage) {
            final compressedFile = await compressImage(File(image.path!));
            final mediaType = MediaType('image', ext == 'jpg' ? 'jpeg' : ext);

            request.files.add(
              await http.MultipartFile.fromPath(
                'Images',
                compressedFile.path,
                contentType: mediaType,
              ),
            );
          } else {
            if (kDebugMode) {
              print('⚠️ Unsupported image type: $ext');
            }
          }
        }
      }
      if (video != null) {
        try {
          final compressedVideo = await VideoCompress.compressVideo(
            video.path!,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
          );

          final videoFile = compressedVideo?.file ?? File(video.path!);

          request.files.add(
            await http.MultipartFile.fromPath(
              'Video',
              videoFile.path,
              contentType: MediaType('video', 'mp4'),
            ),
          );
        } catch (err) {
          if (kDebugMode) {
            print("⚠️ Video compression failed, sending original: $err");
          }
          request.files.add(
            await http.MultipartFile.fromPath(
              'Video',
              video.path!,
              contentType: MediaType('video', 'mp4'),
            ),
          );
        }
      }

      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('📡 Report API Status: ${response.statusCode}');
        print('🧾 Report API Body: $responseBody');
      }

      if (responseBody.trim().isEmpty) {
        return {
          "success": response.statusCode == 201,
          "message":
              "Không có phản hồi từ server. Mã trạng thái: ${response.statusCode}",
        };
      }

      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": responseData['message'] ?? "Gửi báo cáo thành công",
          "data": responseData['data'],
        };
      }

      return {
        "success": false,
        "message": responseData['message'] ?? "Không gửi được báo cáo",
      };
    } catch (e) {
      if (kDebugMode) {
        print("❌ Lỗi gửi báo cáo: $e");
      }
      return {"success": false, "message": "Lỗi không xác định: $e"};
    }
  }

  Future<List<ReportHistoryModel>> fetchReportHistory({
    String? range,
    String? status,
    String? sort,
    String? priority,
    String? communeName,
  }) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception("Token missing");

    final queryParams = {
      'range': range ?? '',
      'status': status ?? '',
      'sort': sort ?? '',
      'priorityFilter': priority ?? '',
      'communeName': communeName ?? '',
    };

    final uri = Uri.parse(
      "${apiConnection}reports/history/citizen/filter",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List reports = body['data'];
      return reports.map((json) => ReportHistoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load report history');
    }
  }

  Future<Map<String, dynamic>> fetchReportMetadata() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception("Token is missing");

    final uri = Uri.parse("${apiConnection}reports/metadata");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Failed to fetch metadata");
    }
  }

  Future<Map<String, dynamic>> cancelReport(String reportId, String message) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception("Token missing");

    final uri = Uri.parse("${apiConnection}reports/$reportId/cancel");

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'message': message}),
    );

    final jsonBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': jsonBody['message'],
        'data': jsonBody['data'],
      };
    } else {
      return {
        'success': false,
        'message': jsonBody['message'] ?? 'Không thể hủy báo cáo',
      };
    }
  }

    static Future<File> compressImage(File file, {int quality = 70}) async {
    final rawImage = img.decodeImage(await file.readAsBytes());
    if (rawImage == null) return file;

    final compressed = img.encodeJpg(rawImage, quality: quality);
    final newPath = '${file.parent.path}/compressed_${path.basename(file.path)}';
    final compressedFile = File(newPath)..writeAsBytesSync(compressed);
    return compressedFile;
    }
}
