import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Авторизация без сервера: доступен только гостевой режим.
///
/// Используется, пока Firebase не настроен (`flutterfire configure`),
/// а также в тестах. Флаг «вошёл как гость» хранится в SharedPreferences,
/// поэтому после перезапуска экран входа не показывается снова.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs)
    : _user = (_prefs.getBool(guestKey) ?? false)
          ? const AppUser.guest()
          : null;

  static const guestKey = 'auth.guest';

  final SharedPreferences _prefs;
  AppUser? _user;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  bool get supportsAccounts => false;

  static const _unavailable = AuthFailure(AuthErrorCode.unavailable);

  @override
  Future<void> signInWithEmail(String email, String password) async =>
      throw _unavailable;

  @override
  Future<void> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async => throw _unavailable;

  @override
  Future<void> signInWithGoogle() async => throw _unavailable;

  @override
  Future<void> sendPasswordReset(String email) async => throw _unavailable;

  @override
  Future<void> continueAsGuest() async {
    await _prefs.setBool(guestKey, true);
    _set(const AppUser.guest());
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(guestKey);
    _set(null);
  }

  void _set(AppUser? user) {
    _user = user;
    _controller.add(user);
  }
}
