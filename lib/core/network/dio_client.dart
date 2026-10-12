import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/failures.dart';

/// Создаёт настроенный экземпляр [Dio]: таймауты, заголовки, логирование.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }
  return dio;
}

/// Превращает [DioException] в доменную ошибку [Failure].
Failure mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutFailure(e.message);
    case DioExceptionType.badResponse:
      return ServerFailure(e.response?.statusCode, e.message);
    case DioExceptionType.connectionError:
      return NetworkFailure(e.message);
    default:
      // transformTimeout, cancel, badCertificate, unknown и будущие типы.
      return e.error is FormatException
          ? ParsingFailure(e.message)
          : NetworkFailure(e.message);
  }
}
