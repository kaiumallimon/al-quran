/// Generic wrapper for alquran.cloud API responses.
class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  final int code;
  final String status;
  final T data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      status: json['status'] as String,
      data: fromJsonT(json['data']),
    );
  }
}
