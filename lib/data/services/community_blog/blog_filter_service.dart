import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../features/community_blog/models/commune_model.dart';

class BlogFilterService {
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<List<String>> getProvinces() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('${apiConnection}provinces'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((item) => item['name'].toString()).toList();
    } else {
      throw Exception('Failed to fetch provinces');
    }
  }

  Future<List<CommuneModel>> getCommunesByProvinceId(int provinceId) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('${apiConnection}communes/province/$provinceId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];
      return data.map((item) => CommuneModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch communes');
    }
  }

  Future<int?> getCommuneIdByName(String communeName, int provinceId) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('${apiConnection}communes/province/$provinceId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];
      final match = data.firstWhere(
            (item) => item['name'] == communeName,
        orElse: () => null,
      );
      return match != null ? match['id'] : null;
    } else {
      throw Exception('Failed to fetch commune ID');
    }
  }
}
