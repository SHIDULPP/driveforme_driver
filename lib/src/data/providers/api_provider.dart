import 'dart:convert';

import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/services/api_logger.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String baseUrl;
  final String apiKey;
  final SecureStorageService secureStorage;
  final http.Client _client;

  ApiProvider({
    required this.baseUrl,
    required this.apiKey,
    required this.secureStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders({
    bool requireUserId = false,
    bool requireAuth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
    };

    if (apiKey.isNotEmpty) {
      headers['x-api-key'] = apiKey;
    }

    if (requireAuth) {
      final token = await secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw StateError('No auth token found. Please log in again.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

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
    bool requireAuth = false,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final requestUri = queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    try {
      final headers = await _buildHeaders(
        requireUserId: requireUserId,
        requireAuth: requireAuth,
      );

      final stopwatch = Stopwatch()..start();
      ApiLogger.request(method: 'GET', uri: requestUri, headers: headers);

      final response = await _client.get(requestUri, headers: headers);

      stopwatch.stop();
      ApiLogger.response(
        method: 'GET',
        uri: requestUri,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return _parseResponse(response);
    } on StateError catch (e) {
      ApiLogger.error(method: 'GET', uri: requestUri, error: e);
      return ApiResponse.error(e.message);
    } catch (e) {
      ApiLogger.error(method: 'GET', uri: requestUri, error: e);
      return ApiResponse.error('Failed to connect to the server.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireUserId = false,
    bool requireAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final encodedBody = json.encode(data);

    try {
      final headers = await _buildHeaders(
        requireUserId: requireUserId,
        requireAuth: requireAuth,
      );

      final stopwatch = Stopwatch()..start();
      ApiLogger.request(
        method: 'PATCH',
        uri: uri,
        headers: headers,
        body: encodedBody,
      );

      final response = await _client.patch(
        uri,
        headers: headers,
        body: encodedBody,
      );

      stopwatch.stop();
      ApiLogger.response(
        method: 'PATCH',
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return _parseResponse(response);
    } on StateError catch (e) {
      ApiLogger.error(method: 'PATCH', uri: uri, error: e);
      return ApiResponse.error(e.message);
    } catch (e) {
      ApiLogger.error(method: 'PATCH', uri: uri, error: e);
      return ApiResponse.error('Failed to connect to the server.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    bool requireUserId = false,
    bool requireAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final headers = await _buildHeaders(
        requireUserId: requireUserId,
        requireAuth: requireAuth,
      );

      final stopwatch = Stopwatch()..start();
      ApiLogger.request(method: 'DELETE', uri: uri, headers: headers);

      final response = await _client.delete(uri, headers: headers);

      stopwatch.stop();
      ApiLogger.response(
        method: 'DELETE',
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return _parseResponse(response);
    } on StateError catch (e) {
      ApiLogger.error(method: 'DELETE', uri: uri, error: e);
      return ApiResponse.error(e.message);
    } catch (e) {
      ApiLogger.error(method: 'DELETE', uri: uri, error: e);
      return ApiResponse.error('Failed to connect to the server.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireUserId = false,
    bool requireAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final encodedBody = json.encode(data);

    try {
      final headers = await _buildHeaders(
        requireUserId: requireUserId,
        requireAuth: requireAuth,
      );

      final stopwatch = Stopwatch()..start();
      ApiLogger.request(
        method: 'POST',
        uri: uri,
        headers: headers,
        body: encodedBody,
      );

      final response = await _client.post(
        uri,
        headers: headers,
        body: encodedBody,
      );

      stopwatch.stop();
      ApiLogger.response(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return _parseResponse(response);
    } on StateError catch (e) {
      ApiLogger.error(method: 'POST', uri: uri, error: e);
      return ApiResponse.error(e.message);
    } catch (e) {
      ApiLogger.error(method: 'POST', uri: uri, error: e);
      return ApiResponse.error('Failed to connect to the server.');
    }
  }

  ApiResponse<Map<String, dynamic>> _parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      return ApiResponse.error(
        'Empty response from server.',
        response.statusCode,
      );
    }

    final dynamic decodedBody = json.decode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      return ApiResponse.error(
        'Unexpected response format.',
        response.statusCode,
      );
    }

    final message = decodedBody['message'] as String? ?? 'Request failed';

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(decodedBody, response.statusCode);
    }

    return ApiResponse.error(message, response.statusCode);
  }

  void dispose() => _client.close();
}

final apiProviderProvider = Provider<ApiProvider>((ref) {
  final baseUrl = dotenv.env['BASE_URL'] ?? '';
  final apiKey = dotenv.env['API_KEY'] ?? '';

  return ApiProvider(
    baseUrl: baseUrl,
    apiKey: apiKey,
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});
