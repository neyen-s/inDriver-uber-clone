import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/sesion_manager.dart';

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

        default:
          throw UnimplementedError('Method $method not implemented');
      }

      return _handleResponse(response);
    } on TokenExpiredException {
      debugPrint('Token expired. 401');

      final newToken = await _refreshToken();
      if (newToken != null) {
        headers?['Authorization'] = 'Bearer $newToken';
        return _handleRequest(
          method: method,
          uri: uri,
          headers: headers,
          body: body,
          timeout: timeout,
        );
      } else {
        rethrow;
      }
    } catch (e) {
      if (e is TokenExpiredException) rethrow;
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

      return _handleResponse(response);
    } on TokenExpiredException {
      debugPrint('Token expired. 401');

      final newToken = await _refreshToken();
      if (newToken != null) {
        headers?['Authorization'] = 'Bearer $newToken';
        return _handleMultipartPut(
          uri: uri,
          headers: headers,
          fields: fields,
          file: file,
          timeout: timeout,
        );
      } else {
        rethrow;
      }
    } catch (e) {
      if (e is TokenExpiredException) rethrow;
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
    final statusCode = response.statusCode;
    final responseBody = response.body;

    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

      if (statusCode >= 200 && statusCode < 300) {
        return decoded;
      }

      if (statusCode == 401) {
        final isTokenExpired =
            decoded['code'] == 'token_not_valid' &&
            ((decoded['messages'] as List<dynamic>?)?.any(
                  (msg) => msg['message'] == 'Token is expired',
                ) ??
                false);

        if (isTokenExpired) {
          throw const TokenExpiredException(message: 'Token expired');
        }
      }

      final message = decoded['message']?.toString() ?? 'Unknown error';
      throw ServerException(message: message, statusCode: '$statusCode');
    } catch (e) {
      debugPrint('Error decoding response: $responseBody');

      // Si es un 401 pero no se pudo parsear JSON, lanza TokenExpiredException igual por seguridad.
      if (statusCode == 401) {
        throw const TokenExpiredException(message: 'Token expired');
      }

      throw ServerException(
        message: 'Invalid JSON response',
        statusCode: '$statusCode',
      );
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await SessionManager.refreshToken;

      if (refreshToken == null) {
        SessionManager.handleTokenExpired();
        return null;
      }

      final response = await post(
        path: '/auth/refresh',
        body: {'refresh': refreshToken},
      );

      final newAccessToken =
          response['access']
              as String?; //TODO check later the real name of the variable

      if (newAccessToken != null) {
        await SessionManager.updateAccessToken(newAccessToken);
        return newAccessToken;
      } else {
        SessionManager.handleTokenExpired();
        return null;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
    return null;
  }
}
