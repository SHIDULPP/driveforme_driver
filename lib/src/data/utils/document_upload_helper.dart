import 'dart:io';

import 'package:driveforme_driver/src/data/models/document_upload_result.dart';
import 'package:driveforme_driver/src/data/services/upload_service.dart';
import 'package:driveforme_driver/src/interfaces/components/media_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<DocumentUploadResult?> pickAndUploadDocumentImage({
  required BuildContext context,
  required UploadService uploadService,
  ImageSource? source,
  String folder = 'driver-documents',
  bool cameraOnly = false,
}) async {
  final picker = ImagePicker();
  XFile? pickedFile;

  if (cameraOnly || source == ImageSource.camera) {
    final granted = await _requestCameraPermission();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return null;
    }
    pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
  } else if (source == ImageSource.gallery) {
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
  } else {
    final result = await pickMedia(
      context: context,
      showDocument: false,
      allowVideo: false,
    );

    if (result is XFile) {
      pickedFile = result;
    }
  }

  if (pickedFile == null) return null;

  final imageUrl = await uploadService.uploadImageFile(
    pickedFile.path,
    folder: folder,
  );

  return DocumentUploadResult(
    imageUrl: imageUrl,
    localPath: pickedFile.path,
  );
}

Future<bool> _requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted || status.isLimited;
}

File? localPreviewFile(String? localPath) {
  if (localPath == null || localPath.isEmpty) return null;
  final file = File(localPath);
  return file.existsSync() ? file : null;
}
