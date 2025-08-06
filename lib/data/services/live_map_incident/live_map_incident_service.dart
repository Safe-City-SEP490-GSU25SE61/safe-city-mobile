import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../features/incident_live_map/models/live_map_report_detail_model.dart';

class LiveMapIncidentService {
  static final _storage = const FlutterSecureStorage();
  static final String apiConnection = dotenv.env['API_DEPLOYMENT_URL']!;

  Future<List<Map<String, dynamic>>> fetchCommunesPolygon() async {
    final response = await http.get(Uri.parse('${apiConnection}map/communes'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> results = [];

      final List<dynamic> rawList = json.decode(response.body);
      for (var item in rawList) {
        final polygonStr = item['polygon'];
        if (polygonStr != null && polygonStr is String) {
          final parsedJson = json.decode(polygonStr);
          results.add(parsedJson);
        }
      }

      return results;
    } else {
      throw Exception('Failed to load communes');
    }
  }

  Future<Map<String, int>> fetchReportsByType({
    required String communeId,
    required String range,
  }) async {
    final url = Uri.parse(
      '${apiConnection}map/reports?CommuneId=$communeId&Range=$range',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reportsByType = Map<String, dynamic>.from(
        data['reportsByType'] ?? {},
      );
      return reportsByType.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to fetch reports');
    }
  }

  Future<List<ReportDetailModel>> fetchReportDetailsByType({
    required String communeId,
    required String type,
    required String range,
  }) async {
    final url = Uri.parse(
      '${apiConnection}map/reports/details?CommuneId=$communeId&Type=$type&Range=$range',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((item) => ReportDetailModel.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to fetch report details');
    }
  }
}
