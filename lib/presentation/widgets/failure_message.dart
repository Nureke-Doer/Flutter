import '../../core/error/failures.dart';
import '../../l10n/generated/app_localizations.dart';

/// Понятный пользователю текст для доменной ошибки.
String failureMessage(AppLocalizations l10n, Failure? failure) {
  return switch (failure) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    ServerFailure(:final statusCode) => l10n.errorServer(
      '${statusCode ?? '?'}',
    ),
    ParsingFailure() => l10n.errorParsing,
    UnknownFailure() || null => l10n.errorUnknown,
  };
}
