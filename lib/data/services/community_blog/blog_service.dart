import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:safe_city_mobile/features/community_blog/models/blog_history_model.dart';

import '../../../features/community_blog/models/blog_comment_model.dart';
import '../../../features/community_blog/models/blog_models.dart';
import '../../../features/community_blog/models/commune_model.dart';
import '../../../features/community_blog/models/province_with_commune_model.dart';

class BlogService {
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  List<ProvinceWithCommunesModel> _cachedProvinces = [];
  List<ProvinceWithCommunesModel> get cachedProvinces => _cachedProvinces;

  Future<String?> _getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>> getBlogsByCommuneId(
      int communeId, {
        String? title,
        String? blogType,
        int page = 1,
        int pageSize = 10,
        bool isFirstRequest = false,
      }) async {
    final token = await _getAccessToken();

    final uri = Uri.parse(
      '${apiConnection}blogs/user?CommuneId=$communeId'
          '&PageNumber=$page&PageSize=$pageSize'
          '${title != null && title.isNotEmpty ? '&Title=$title' : ''}'
          '${blogType != null && blogType.isNotEmpty ? '&Type=$blogType' : ''}'
          '&isFirstRequest=$isFirstRequest',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (isFirstRequest && decoded['data']?['provinces'] != null) {
        final List provinceList = decoded['data']['provinces'];
        _cachedProvinces = provinceList
            .map((item) => ProvinceWithCommunesModel.fromJson(item))
            .toList();
      }

      final List blogList = decoded['data']?['blogs'] ?? [];

      final bool isPremium = decoded['data']?['isPremium'] ?? true;

      final blogs = blogList.map<BlogModel>((item) {
        final String provinceName = item['provinceName'] ?? '';
        final String communeName = item['communeName'] ?? '';

        final province = _cachedProvinces.firstWhere(
              (p) => p.name == provinceName,
          orElse: () => ProvinceWithCommunesModel(id: -1, name: 'Unknown', communes: []),
        );

        final commune = province.communes.firstWhere(
              (c) => c.name == communeName,
          orElse: () => CommuneModel(id: -1, name: 'Unknown'),
        );

        return BlogModel.fromJson(item, province: province, commune: commune);
      }).toList();

      return {
        'blogs': blogs,
        'isPremium': isPremium,
      };
    } else {
      throw Exception('Failed to fetch blogs');
    }
  }

  int? getCommuneIdByName(String provinceName, String communeName) {
    final province = _cachedProvinces.firstWhereOrNull(
          (p) => p.name.trim().toLowerCase() == provinceName.trim().toLowerCase(),
    );

    if (province == null) {
      if (kDebugMode) {
        print('[DEBUG] Province not found: "$provinceName"');
      }
      return null;
    }

    final commune = province.communes.firstWhereOrNull(
          (c) => c.name.trim().toLowerCase() == communeName.trim().toLowerCase(),
    );

    if (commune == null) {
      if (kDebugMode) {
        print('[DEBUG] Commune not found: "$communeName" in "${province.name}"');
        print('[DEBUG] Available communes: ${province.communes.map((c) => c.name).join(', ')}');
      }
    }

    return commune?.id;
  }

  Future<void> toggleLike(int blogId) async {
    final token = await _getAccessToken();
    final response = await http.post(
      Uri.parse('${apiConnection}blogs/like/$blogId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like/unlike blog');
    }
  }

  Future<List<CommentModel>> getCommentsByBlogId(int blogId) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('${apiConnection}comments/$blogId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  Future<void> postComment({required int blogId, required String content,}) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('${apiConnection}comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode({'blogId': blogId, 'content': content}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to post comment');
    }
  }

  Future<Map<String, dynamic>> submitBlog({required String title, required String content, required String type, required int communeId, required List<PlatformFile> images, required PlatformFile? video,}) async {
    final uri = Uri.parse('${apiConnection}blogs');
    final request = http.MultipartRequest('POST', uri);

    try {
      request.fields['Title'] = title;
      request.fields['Content'] = content;
      request.fields['Type'] = type;
      request.fields['CommuneId'] = communeId.toString();

      for (var image in images) {
        final ext = path.extension(image.path!).replaceFirst('.', '').toLowerCase();
        final isImage = ['jpg', 'jpeg', 'png'].contains(ext);

        if (isImage) {
          final mediaType = MediaType('image', ext == 'jpg' ? 'jpeg' : ext);
          request.files.add(
            await http.MultipartFile.fromPath(
              'MediaFiles',
              image.path!,
              contentType: mediaType,
            ),
          );
        } else {
          if (kDebugMode) {
            print('⚠️ Unsupported image format: $ext');
          }
        }
      }

      if (video != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'MediaFiles',
            video.path!,
            contentType: MediaType('video', 'mp4'),
          ),
        );
      }

      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('📡 Blog API Status: ${response.statusCode}');
        print('🧾 Blog API Body: $responseBody');
      }

      if (responseBody.trim().isEmpty) {
        return {
          "success": response.statusCode == 200,
          "message": "Không có phản hồi từ server. Mã trạng thái: ${response.statusCode}",
        };
      }

      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Blog đã được tạo thành công.",
          "data": responseData,
        };
      }

      return {
        "success": false,
        "message": responseData['message'] ?? "Tạo blog thất bại.",
      };
    } catch (e) {
      if (kDebugMode) {
        print("❌ Lỗi gửi blog: $e");
      }
      return {
        "success": false,
        "message": "Đã xảy ra lỗi không xác định: $e",
      };
    }
  }

  Future<List<BlogHistoryModel>> fetchUserCreatedBlogs() async {
    final token = await _getAccessToken();

    final uri = Uri.parse('${apiConnection}blogs/created-blogs');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List blogList = decoded['data'] ?? [];

      return blogList.map<BlogHistoryModel>((item) {
        return BlogHistoryModel.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to fetch user created blogs');
    }
  }
}
