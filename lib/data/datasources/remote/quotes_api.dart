import 'package:dio/dio.dart';

import '../../models/quote_dto.dart';

/// Удалённый источник мотивационных цитат: https://dummyjson.com/docs/quotes
class QuotesApi {
  QuotesApi(this._dio);

  static const baseUrl = 'https://dummyjson.com';

  final Dio _dio;

  Future<QuoteDto> random() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/quotes/random',
    );
    return QuoteDto.fromJson(response.data ?? const {});
  }
}
