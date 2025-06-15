import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:safe_city_mobile/data/services/authentication/token_manager.dart';
import '../../../features/authentication/screens/login/login.dart';

class HttpInterceptor extends http.BaseClient {
  final http.Client _client = http.Client();

  bool _isRefreshing = false;
  Future<void>? _refreshFuture;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var accessToken = await TokenManager().getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    var response = await _client.send(request);

    if (response.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshFuture = TokenManager().refreshTokenIfNeeded();
      }
      await _refreshFuture;
      _isRefreshing = false;

      accessToken = await TokenManager().getAccessToken();
      if (accessToken != null) {
        final newRequest = _cloneRequest(request, accessToken);
        response = await _client.send(newRequest);
      } else {
        await TokenManager().clearTokens();
        Get.to(() => const LoginScreen());
        throw Exception('Session expired. Please login again.');
      }
    }

    return response;
  }

  /// Clone request for retry
  http.BaseRequest _cloneRequest(http.BaseRequest request, String accessToken) {
    final newRequest = http.Request(request.method, request.url);
    newRequest.headers.addAll(request.headers);
    newRequest.headers['Authorization'] = 'Bearer $accessToken';

    if (request is http.Request) {
      newRequest.bodyBytes = request.bodyBytes;
    }

    return newRequest;
  }
}
