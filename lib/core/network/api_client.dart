import 'dart:io';

import 'package:indriver_uber_clone/core/utils/typedefs.dart';

abstract class ApiClient {
  Future<DataMap> post({
    required String path,
    Map<String, String>? headers,
    DataMap? body,
    Duration timeout = const Duration(seconds: 3),
  });

  Future<DataMap> put({
    required String path,
    Map<String, String>? headers,
    DataMap? body,
    Map<String, String>? fields,
    File? file,
    Duration timeout = const Duration(seconds: 3),
  });

  Future<DataMap> delete({
    required String path,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 3),
  });

  // Add more when needed
  // Future<DataMap> get(...);
}
