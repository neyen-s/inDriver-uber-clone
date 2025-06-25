import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({required this.baseUrl});
  final String baseUrl;

  @override
  Future<DataMap> post({
    required String path,
    Map<String, String>? headers,
    DataMap? body,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final uri = Uri.http(baseUrl, path);
    final requestHeaders = {'Content-Type': 'application/json', ...?headers};

    try {
      debugPrint('POST Request: $uri');
      final response = await http
          .post(uri, headers: requestHeaders, body: jsonEncode(body))
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      debugPrint('No Internet connection. 503');
      throw const ServerException(
        message: 'No Internet connection.',
        statusCode: '503',
      );
    } on TimeoutException {
      debugPrint('Request timed out. 408');
      throw const ServerException(
        message: 'Request timed out.',
        statusCode: '408',
      );
    } on ServerException {
      rethrow; // Mantener los errores originales
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw ServerException(
        message: 'Unexpected client error: $e',
        statusCode: '500',
      );
    }
  }

  DataMap _handleResponse(http.Response response) {
    late final DataMap decoded;

    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      debugPrint('Error decoding JSON response: ${response.body}');
      throw ServerException(
        message: 'Invalid JSON response',
        statusCode: response.statusCode.toString(),
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded['message']?.toString() ?? 'Unknown error';
    throw ServerException(
      message: message,
      statusCode: response.statusCode.toString(),
    );
  }
}
