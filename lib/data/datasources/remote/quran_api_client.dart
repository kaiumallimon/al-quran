import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';

/// Low-level HTTP client for alquran.cloud API.
class QuranApiClient {
  QuranApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _tag = 'QuranApiClient';

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    AppLogger.info(_tag, 'GET $uri');

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      AppLogger.error(_tag, 'Network error', e);
      throw NetworkException('Unable to connect. Please check your internet.');
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error(_tag, 'Unexpected error', e);
      throw NetworkException('Something went wrong. Please try again.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 404) {
      throw const ApiException('Resource not found.', statusCode: 404);
    }

    if (response.statusCode != 200) {
      throw ApiException(
        'Server returned an error.',
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final code = body['code'] as int?;

    if (code != 200) {
      final data = body['data'];
      final message = data is String ? data : 'Request failed.';
      throw ApiException(message, statusCode: code);
    }

    return body;
  }

  Future<ApiResponse<T>> getTyped<T>(
    String path,
    T Function(dynamic) fromJsonT,
  ) async {
    final body = await get(path);
    return ApiResponse.fromJson(body, fromJsonT);
  }

  void dispose() => _client.close();
}
