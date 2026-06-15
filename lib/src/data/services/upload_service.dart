import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';

/// Uploads files to `POST /upload` (requires `x-user-id` header).
class UploadService {
  final SecureStorageService _secureStorage;

  UploadService(this._secureStorage);

  Future<String> uploadImageFile(
    String imagePath, {
    String folder = 'driver-documents',
  }) async {
    File imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      throw Exception('Image file not found');
    }

    Uint8List imageBytes = await imageFile.readAsBytes();
    log(
      'Original image size: ${(imageBytes.lengthInBytes / 1024).toStringAsFixed(2)} KB',
      name: 'UploadService',
    );

    final String? mimeType = lookupMimeType(imagePath, headerBytes: imageBytes);

    if (imageBytes.lengthInBytes > 2 * 1024 * 1024) {
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage != null) {
        final resizedImage = img.copyResize(
          decodedImage,
          width: (decodedImage.width * 0.5).toInt(),
        );
        imageBytes = Uint8List.fromList(
          img.encodeJpg(resizedImage, quality: 80),
        );
        imageFile = await imageFile.writeAsBytes(imageBytes);
        log(
          'Compressed image size: ${(imageBytes.lengthInBytes / 1024).toStringAsFixed(2)} KB',
          name: 'UploadService',
        );
      }
    }

    return _uploadFile(
      file: imageFile,
      mimeType: mimeType ?? 'image/jpeg',
      folder: folder,
    );
  }

  Future<String> _uploadFile({
    required File file,
    required String mimeType,
    required String folder,
  }) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      throw Exception('BASE_URL is missing from .env');
    }

    final userId = await _secureStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('User session not found. Please log in again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );

    request.headers['x-user-id'] = userId;
    request.fields['folder'] = folder;

    final parts = mimeType.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(parts.first, parts.last),
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return _extractFileUrl(responseBody);
    }

    log('Upload failed: $responseBody', name: 'UploadService');
    final message = _extractErrorMessage(responseBody);
    throw Exception(message);
  }

  String _extractFileUrl(String responseBody) {
    final responseJson = jsonDecode(responseBody) as Map<String, dynamic>;
    final data = responseJson['data'];
    if (data is String && data.isNotEmpty) {
      return data;
    }
    throw Exception('Invalid upload response');
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final responseJson = jsonDecode(responseBody) as Map<String, dynamic>;
      final message = responseJson['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {}
    return 'Failed to upload image';
  }
}

final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(ref.watch(secureStorageServiceProvider));
});
