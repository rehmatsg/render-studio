import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';

import '../rehmat.dart';

class Cloud {

  static final String baseUrl = 'https://render-studio-cloud-production.up.railway.app/';

  static Future<String?> get token => AuthState.instance.user!.getIdToken();

  static final _dio = Dio(
    BaseOptions(
      baseUrl: Cloud.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      }
    )
  );

  static Future<Response<T>> post<T>(String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    /// Whether to use the auth bearer token or not
    /// Defaults to `true`
    bool useToken = true
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            if (useToken) HttpHeaders.authorizationHeader: 'Bearer ${await token}',
            HttpHeaders.contentTypeHeader: "multipart/form-data",
          }
        )
      );
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'Cloud.post failed');
      rethrow;
    }
  }

  static Future<Response<T>> get<T>(String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool useToken = true
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {
            if (useToken) 'Authorization': 'Bearer ${await token}'
          }
        )
      );
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'Cloud.get failed');
      rethrow;
    }
  }

}