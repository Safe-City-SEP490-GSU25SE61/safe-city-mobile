import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../features/community_blog/models/blog_comment_model.dart';
import '../../../features/community_blog/models/blog_models.dart';

class BlogService {
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<List<BlogModel>> getBlogsByCommuneId(int communeId) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('${apiConnection}blogs/user/commune/$communeId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];
      return data.map((item) => BlogModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch blogs by communeId');
    }
  }

  Future<void> toggleLike(int blogId) async {
    final token = await _getAccessToken();
    final response = await http.post(
      Uri.parse('${apiConnection}blogs/like/$blogId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like/unlike blog');
    }
  }

  Future<List<CommentModel>> getCommentsByBlogId(int blogId) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('${apiConnection}comments/$blogId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  Future<void> postComment({required int blogId, required String content}) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('${apiConnection}comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode({
        'blogId': blogId,
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to post comment');
    }
  }
}
