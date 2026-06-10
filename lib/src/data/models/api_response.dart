class ApiResponse<T> {
  final bool success;
  final T? data;
  final int? statusCode;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.statusCode,
    this.message,
  });

  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

Map<String, dynamic>? nestedData(Map<String, dynamic>? body) {
  final data = body?['data'];
  if (data is Map<String, dynamic>) return data;
  return null;
}
