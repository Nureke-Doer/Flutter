import '../entities/app_user.dart';

/// Причины ошибок входа — UI превращает их в понятный текст.
enum AuthErrorCode {
  invalidEmail,
  wrongCredentials,
  emailInUse,
  weakPassword,
  network,
  cancelled,
  tooManyRequests,

  /// Вход через аккаунт недоступен (Firebase не настроен).
  unavailable,
  unknown,
}

/// Ошибка авторизации.
class AuthFailure implements Exception {
  const AuthFailure(this.code, [this.message]);

  final AuthErrorCode code;
  final String? message;

  @override
  String toString() => 'AuthFailure($code, $message)';
}

/// Контракт авторизации (паттерн Repository).
///
/// Неделя 7 — локальная реализация (только гость), неделя 8 — Firebase
/// Authentication (email и Google). Роутер и экраны зависят только от
/// этого интерфейса.
abstract interface class AuthRepository {
  /// Текущий пользователь (`null` — не вошёл).
  AppUser? get currentUser;

  /// Поток изменений: вход, выход, смена аккаунта.
  Stream<AppUser?> authStateChanges();

  /// Доступны ли вход по email и Google (настроен ли Firebase).
  bool get supportsAccounts;

  Future<void> signInWithEmail(String email, String password);

  Future<void> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  /// Работать без аккаунта: данные только на устройстве.
  Future<void> continueAsGuest();

  Future<void> signOut();
}
