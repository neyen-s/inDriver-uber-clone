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
    return _handleRequest(
      method: 'POST',
      uri: Uri.http(baseUrl, path),
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  @override
  Future<DataMap> put({
    required String path,
    Map<String, String>? headers,
    DataMap? body,
    Map<String, String>? fields,
    File? file,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final uri = Uri.parse('http://$baseUrl$path');

    if (file != null || fields != null) {
      return _handleMultipartPut(
        uri: uri,
        headers: headers,
        fields: fields,
        file: file,
        timeout: timeout,
      );
    }

    return _handleRequest(
      method: 'PUT',
      uri: uri,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  Future<DataMap> _handleRequest({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    DataMap? body,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final requestHeaders = {'Content-Type': 'application/json', ...?headers};

    try {
      debugPrint('$method Request: $uri');

      late final http.Response response;
      final encodedBody = jsonEncode(body);

      switch (method) {
        case 'POST':
          response = await http
              .post(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
        case 'PUT':
          response = await http
              .put(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
          print('***Decoded response: ${response.body}');

        default:
          throw UnimplementedError('Method $method not implemented');
      }
      print('Decoded response: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      throw _handleHttpError(e);
    }
  }

  Future<DataMap> _handleMultipartPut({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? fields,
    File? file,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      debugPrint('PUT Multipart Request: $uri');

      final request = http.MultipartRequest('PUT', uri)
        ..headers.addAll({...?headers});

      if (fields != null) request.fields.addAll(fields);
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      print('/******Decoded response: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      throw _handleHttpError(e);
    }
  }

  Exception _handleHttpError(Object e) {
    if (e is SocketException) {
      debugPrint('No Internet connection. 503');
      return const ServerException(
        message: 'No Internet connection.',
        statusCode: '503',
      );
    } else if (e is TimeoutException) {
      debugPrint('Request timed out. 408');
      return const ServerException(
        message: 'Request timed out.',
        statusCode: '408',
      );
    } else if (e is TokenExpiredException) {
      debugPrint('Token expired. 401');
      return const TokenExpiredException(message: 'Token expired.');
    } else if (e is ServerException) {
      return e;
    } else {
      debugPrint('Unexpected error: $e');
      return ServerException(
        message: 'Unexpected client error: $e',
        statusCode: '500',
      );
    }
  }

  DataMap _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      if (response.statusCode == 401) {
        final isTokenExpired =
            decoded['code'] == 'token_not_valid' &&
            (decoded['messages'] as List<dynamic>?)?.any(
                  (msg) => msg['message'] == 'Token is expired',
                ) ==
                true;

        if (isTokenExpired) {
          throw const TokenExpiredException(message: 'Token expired');
        }
      }

      final message = decoded['message']?.toString() ?? 'Unknown error';
      throw ServerException(
        message: message,
        statusCode: response.statusCode.toString(),
      );
    } catch (e) {
      debugPrint('Error decoding response: ${response.body}');
      throw ServerException(
        message: 'Invalid JSON response',
        statusCode: response.statusCode.toString(),
      );
    }
  }
}
