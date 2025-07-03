import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../features/personalization/models/subcription_package_model.dart';

class SubscriptionService {
  var client = http.Client();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<SubscriptionPackageModel>> fetchActivePackages() async {
    final url = Uri.parse('${apiConnection}packages');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List packages = body['data'];
      return packages
          .map((json) => SubscriptionPackageModel.fromJson(json))
          .where((pkg) => pkg.isActive)
          .toList();
    } else {
      throw Exception('Failed to load subscription packages');
    }
  }

  Future<String?> createSubscription(int packageId, String token) async {
    final url = Uri.parse(
      '${apiConnection}subscriptions?packageId=$packageId&returnUrl=safe-city://payment-success&cancelUrl=safe-city://payment-cancel',
    );

    final response = await client.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return jsonBody['data']['checkoutUrl'];
    } else {
      if (kDebugMode) {
        print('Failed to create subscription: ${response.body}');
      }
      return null;
    }
  }
}
