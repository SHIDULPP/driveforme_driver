import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<dynamic> pickMedia({
  required BuildContext context,
  bool allowMultiple = false,
  bool showDocument = true,
  bool allowVideo = false,
  bool onlyVideo = false,
}) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MediaPickerDialog(
      allowMultiple: allowMultiple,
      showDocument: showDocument,
      allowVideo: allowVideo,
      onlyVideo: onlyVideo,
    ),
  );
}

class MediaPickerDialog extends StatelessWidget {
  final bool allowMultiple;
  final bool showDocument;
  final bool allowVideo;
  final bool onlyVideo;

  const MediaPickerDialog({
    super.key,
    required this.allowMultiple,
    required this.showDocument,
    required this.allowVideo,
    required this.onlyVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 15,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!onlyVideo) ...[
            _option(
              context,
              "Camera",
              Icons.camera_alt_rounded,
              () => _pickFromCamera(context),
            ),
            _option(
              context,
              "Gallery",
              Icons.photo_library_rounded,
              () => _pickFromGallery(context),
            ),
          ],
          if (allowVideo || onlyVideo) ...[
            _option(
              context,
              "Video Camera",
              Icons.videocam_rounded,
              () => _pickVideo(context, source: ImageSource.camera),
            ),
            _option(
              context,
              "Video Gallery",
              Icons.video_collection_rounded,
              () => _pickVideo(context, source: ImageSource.gallery),
            ),
          ],
          if (showDocument)
            _option(
              context,
              "Document",
              Icons.insert_drive_file_rounded,
              () => _pickDocument(context),
            ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) {
        openAppSettings();
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? rawImage = await picker.pickImage(source: ImageSource.camera);

    if (!context.mounted) return;
    Navigator.pop(context, rawImage);
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();

    if (allowMultiple) {
      final List<XFile> images = await picker.pickMultiImage();
      if (!context.mounted) return;
      Navigator.pop(context, images);
      return;
    }

    final XFile? rawImage = await picker.pickImage(source: ImageSource.gallery);
    if (!context.mounted) return;
    Navigator.pop(context, rawImage);
  }

  Future<void> _pickVideo(
    BuildContext context, {
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: source);
    if (context.mounted) Navigator.pop(context, video);
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: [
        "pdf",
        "doc",
        "docx",
        "xls",
        "xlsx",
        "png",
        "jpg",
        "jpeg",
      ],
    );
    if (context.mounted) Navigator.pop(context, result);
  }
}
