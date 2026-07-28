class DocumentUploadResult {
  final String imageUrl;
  final String localPath;
  final Map<String, dynamic> payload;

  const DocumentUploadResult({
    required this.imageUrl,
    required this.localPath,
    this.payload = const {},
  });
}
