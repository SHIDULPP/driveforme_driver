import 'dart:convert';
import 'dart:developer';

import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String baseUrl;
  final SecureStorageService secureStorage;
  final http.Client _client;

  ApiProvider({
    required this.baseUrl,
    required this.secureStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders({bool requireUserId = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
    };

    if (requireUserId) {
      final userId = await secureStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        headers['x-user-id'] = userId;
      }
    }

    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    bool requireUserId = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await _buildHeaders(requireUserId: requireUserId);
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestUri = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams)
          : uri;

      final response = await _client.get(requestUri, headers: headers);
      return _parseResponse(response);
    } catch (e) {
      log('GET $endpoint failed: $e', name: 'ApiProvider');
      return ApiResponse.error('Failed to connect to the server.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireUserId = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireUserId: requireUserId);
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _parseResponse(response);
    } catch (e) {
      log('POST $endpoint failed: $e', name: 'ApiProvider');
      return ApiResponse.error('Failed to connect to the server.');
    }
  }

  ApiResponse<Map<String, dynamic>> _parseResponse(http.Response response) {
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final message = decoded['message'] as String? ?? 'Request failed';

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(decoded, response.statusCode);
    }

    return ApiResponse.error(message, response.statusCode);
  }

  void dispose() => _client.close();
}

final apiProviderProvider = Provider<ApiProvider>((ref) {
  final baseUrl = dotenv.env['BASE_URL'] ?? '';
  if (baseUrl.isEmpty) {
    log('BASE_URL is missing from .env', name: 'ApiProvider');
  }

  return ApiProvider(
    baseUrl: baseUrl,
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});
