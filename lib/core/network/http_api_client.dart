import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/core/services/secure_storage_adapter.dart';
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

  @override
  Future<DataMap> delete({
    required String path,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return _handleRequest(
      method: 'DELETE',
      uri: Uri.http(baseUrl, path),
      headers: headers,
      timeout: timeout,
    );
  }

  @override
  Future<DataMap> get({
    required String path,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return _handleRequest(
      method: 'GET',
      uri: Uri.http(baseUrl, path),
      headers: headers,
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

    final accessToken = await SessionManager.accessToken;
    if (accessToken != null && !requestHeaders.containsKey('Authorization')) {
      requestHeaders['Authorization'] = 'Bearer $accessToken';
    }
    //

    debugPrint('**** HttpApiClient Handling request ****');
    debugPrint('requestHeaders: $requestHeaders');
    debugPrint('$method Request: $uri');

    try {
      late final http.Response response;
      final encodedBody = jsonEncode(body);

      debugPrint('encodedBody: $encodedBody');

      switch (method) {
        case 'POST':
          response = await http
              .post(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
        case 'PUT':
          response = await http
              .put(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
        case 'DELETE':
          response = await http
              .delete(uri, headers: requestHeaders)
              .timeout(timeout);
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
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
        statusCode: 503,
      );
    } else if (e is TimeoutException) {
      debugPrint('Request timed out. 408');
      return const ServerException(
        message: 'Request timed out.',
        statusCode: 408,
      );
    } else if (e is ServerException) {
      return e;
    } else {
      debugPrint('Unexpected error: $e');
      return ServerException(
        message: 'Unexpected client error: $e',
        statusCode: 500,
      );
    }
  }

  DataMap _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body.trim();

    // Empty
    if (responseBody.isEmpty) {
      debugPrint('Empty response body, returning {}');
      if (statusCode >= 200 && statusCode < 300) return <String, dynamic>{};
      throw ServerException(message: 'Empty response', statusCode: statusCode);
    }
    //tries to parse JSONin a safe way
    try {
      final dynamic decodedRaw = jsonDecode(responseBody);
      debugPrint('decoded: $decodedRaw');
      debugPrint('statusCode: $statusCode');

      if (decodedRaw is List) {
        debugPrint('decoded is List with length: ${decodedRaw.length}');
        if (statusCode >= 200 && statusCode < 300) {
          return <String, dynamic>{'data': decodedRaw};
        }
        final fallbackMsg = decodedRaw.isNotEmpty
            ? decodedRaw.toString()
            : 'Server error';
        throw ServerException(message: fallbackMsg, statusCode: statusCode);
      }

      if (decodedRaw is Map) {
        final decoded = Map<String, dynamic>.from(decodedRaw);

        debugPrint('decoded map: $decoded');

        // OK
        if (statusCode >= 200 && statusCode < 300) {
          debugPrint('Call successful with status $statusCode');
          return decoded;
        }

        //if it is 401 and contains token expired
        if (statusCode == 401) {
          final code = decoded['code']?.toString();
          final messages = decoded['messages'];
          final isTokenExpired =
              code == 'token_not_valid' &&
              messages is List &&
              messages.any(
                (msg) =>
                    msg is Map &&
                    msg['message']?.toString() == 'Token is expired',
              );

          if (isTokenExpired) {
            throw const TokenExpiredException(message: 'Token expired');
          }

          //extracts the message (if not exists, fallback to body)
          final message =
              (decoded['message'] ??
                      decoded['detail'] ??
                      decoded['error'] ??
                      responseBody)
                  .toString();
          throw ServerException(message: message, statusCode: statusCode);
        }

        final message =
            (decoded['message'] ??
                    decoded['detail'] ??
                    decoded['error'] ??
                    responseBody)
                .toString();
        throw ServerException(message: message, statusCode: statusCode);
      }

      throw ServerException(
        message: 'Invalid JSON response type',
        statusCode: statusCode,
      );
    } on FormatException catch (fe) {
      debugPrint('Response body is not valid JSON: $fe -- body: $responseBody');

      // If it is a large HTML (debug page), do not pass all to user.
      final looksLikeHtml =
          responseBody.toLowerCase().contains('<html') ||
          responseBody.toLowerCase().contains('<!doctype');

      if (statusCode >= 500) {
        // 5xx type errors with non-JSON body -> generic server error  to client
        debugPrint(
          'Server returned non-JSON 5xx; '
          'returning generic server error to client.',
        );
        throw ServerException(message: 'Server error', statusCode: statusCode);
      }

      if (looksLikeHtml) {
        //4xx type errors with HTML body -> extract title if possible
        final titleMatch = RegExp(
          '<title>(.*?)</title>',
          caseSensitive: false,
          dotAll: true,
        ).firstMatch(responseBody);
        final extracted = titleMatch?.group(1)?.trim();
        final message = extracted != null && extracted.isNotEmpty
            ? extracted
            : 'Unexpected server response';
        throw ServerException(message: message, statusCode: statusCode);
      }

      // if it's a success status code and the body is not JSON we
      // return it as 'data'
      if (statusCode >= 200 && statusCode < 300) {
        return <String, dynamic>{'data': responseBody};
      }

      //By default we return body (truncated to avoid giant messages)
      final truncated = responseBody.length > 300
          ? '${responseBody.substring(0, 300)}...'
          : responseBody;
      throw ServerException(message: truncated, statusCode: statusCode);
    } catch (e) {
      // Si ya es ServerException lo re-lanzamos
      if (e is ServerException) rethrow;

      // Fallback in case of unexpected error
      debugPrint(
        'Unhandled _handleResponse error: $e -- responseBody: $responseBody',
      );
      final fallbackMessage = responseBody.isNotEmpty
          ? (responseBody.length > 200
                ? '${responseBody.substring(0, 200)}...'
                : responseBody)
          : 'Invalid JSON response';
      throw ServerException(message: fallbackMessage, statusCode: statusCode);
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await SessionManager.refreshToken;
      debugPrint('Refreshing token with refreshToken: $refreshToken');

      if (refreshToken == null) {
        await SessionManager.handleTokenExpired();
        return null;
      }

      //Calls directly with http to avoid recursion in _handleRequest
      final uri = Uri.parse('http://$baseUrl/auth/refresh');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 6));

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('Refresh returned non-2xx: ${resp.statusCode} ${resp.body}');
        await SessionManager.handleTokenExpired();
        return null;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final rawNewAccess =
          (decoded['access'] as String?) ??
          (decoded['access_token'] as String?) ??
          (decoded['token'] as String?);

      if (rawNewAccess == null) {
        await SessionManager.handleTokenExpired();
        return null;
      }

      final newAccess = rawNewAccess.startsWith('Bearer ')
          ? rawNewAccess.substring(7)
          : rawNewAccess;
      final newRefresh =
          (decoded['refresh'] as String?) ??
          (decoded['refreshToken'] as String?) ??
          (decoded['refresh_token'] as String?);

      await SessionManager.updateAccessToken(newAccess);
      if (newRefresh != null) {
        //persisit with a new refresh token if it comes
        await SecureStorageAdapter.writeToken(
          SessionManager.refreshKey,
          newRefresh,
        );
      }
      return newAccess;
    } catch (e, st) {
      debugPrint('Error refreshing token: $e\n$st');
      await SessionManager.handleTokenExpired();
      return null;
    }
  }
}
