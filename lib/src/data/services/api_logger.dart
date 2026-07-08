import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized HTTP logging for backend API calls.
class ApiLogger {
  static const _logName = 'API';

  static bool get enabled {
    final envFlag = dotenv.env['API_LOGGING']?.trim().toLowerCase();
    if (envFlag == 'true') return true;
    if (envFlag == 'false') return false;
    return kDebugMode;
  }

  static void request({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? fields,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('┌─── API REQUEST ───────────────────────────')
      ..writeln('│ $method ${_safeUri(uri)}');

    final safeHeaders = _sanitizeHeaders(headers);
    if (safeHeaders.isNotEmpty) {
      buffer.writeln('│ Headers:');
      for (final entry in safeHeaders.entries) {
        buffer.writeln('│   ${entry.key}: ${entry.value}');
      }
    }

    if (fields != null && fields.isNotEmpty) {
      buffer.writeln('│ Fields:');
      for (final entry in fields.entries) {
        buffer.writeln('│   ${entry.key}: ${entry.value}');
      }
    }

    if (body != null) {
      buffer.writeln('│ Body:');
      for (final line in _formatBody(body).split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.writeln('└───────────────────────────────────────────');
    log(buffer.toString(), name: _logName);
  }

  static void response({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
    Duration? duration,
  }) {
    if (!enabled) return;

    final durationLabel = duration == null
        ? ''
        : ' (${duration.inMilliseconds}ms)';

    final buffer = StringBuffer()
      ..writeln('┌─── API RESPONSE$durationLabel ──────────────────────────')
      ..writeln('│ $method ${_safeUri(uri)}')
      ..writeln('│ Status: $statusCode')
      ..writeln('│ Body:');

    for (final line in _formatBody(body).split('\n')) {
      buffer.writeln('│   $line');
    }

    buffer.writeln('└───────────────────────────────────────────');
    log(buffer.toString(), name: _logName);
  }

  static void error({
    required String method,
    required Uri uri,
    required Object error,
    Duration? duration,
  }) {
    if (!enabled) return;

    final durationLabel = duration == null
        ? ''
        : ' (${duration.inMilliseconds}ms)';

    log(
      '┌─── API ERROR$durationLabel ─────────────────────────────\n'
      '│ $method ${_safeUri(uri)}\n'
      '│ $error\n'
      '└───────────────────────────────────────────',
      name: _logName,
    );
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return const {};

    const sensitiveKeys = {
      'authorization',
      'x-api-key',
      'cookie',
    };

    return {
      for (final entry in headers.entries)
        entry.key: sensitiveKeys.contains(entry.key.toLowerCase())
            ? '***'
            : entry.value,
    };
  }

  static String _formatBody(Object body) {
    if (body is String) {
      if (body.isEmpty) return '(empty)';
      try {
        final decoded = jsonDecode(body);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return body;
      }
    }

    if (body is Map || body is List) {
      return const JsonEncoder.withIndent('  ').convert(body);
    }

    return body.toString();
  }

  static Uri _safeUri(Uri uri) {
    const sensitiveQueryKeys = {'key', 'token', 'api_key', 'apikey'};
    final hasSensitiveQuery = uri.queryParameters.keys.any(
      (key) => sensitiveQueryKeys.contains(key.toLowerCase()),
    );
    if (!hasSensitiveQuery) return uri;

    return uri.replace(
      queryParameters: {
        for (final entry in uri.queryParameters.entries)
          entry.key: sensitiveQueryKeys.contains(entry.key.toLowerCase())
              ? '***'
              : entry.value,
      },
    );
  }
}
