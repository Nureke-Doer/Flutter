/// Ошибки, понятные доменному слою и UI.
///
/// Слой `data` перехватывает низкоуровневые исключения (DioException,
/// FormatException…) и превращает их в один из этих типов. Так UI
/// не зависит от конкретной HTTP-библиотеки.
sealed class Failure implements Exception {
  const Failure([this.details]);

  /// Техническая подробность для логов (не показывается пользователю).
  final String? details;

  @override
  String toString() => '$runtimeType(${details ?? ''})';
}

/// Нет интернета или сервер недоступен.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.details]);
}

/// Сервер не ответил вовремя.
final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.details]);
}

/// Сервер вернул код ошибки (4xx / 5xx).
final class ServerFailure extends Failure {
  const ServerFailure(this.statusCode, [super.details]);

  final int? statusCode;
}

/// Ответ пришёл, но его не удалось разобрать.
final class ParsingFailure extends Failure {
  const ParsingFailure([super.details]);
}

/// Любая другая непредвиденная ошибка.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.details]);
}
