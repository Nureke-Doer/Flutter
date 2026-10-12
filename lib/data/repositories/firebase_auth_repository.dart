import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'local_auth_repository.dart';

/// Код ошибки Firebase Authentication → доменный код.
///
/// Чистая функция: проверяется unit-тестом без Firebase.
AuthErrorCode mapFirebaseAuthError(String code) => switch (code) {
  'invalid-email' => AuthErrorCode.invalidEmail,
  'user-not-found' ||
  'wrong-password' ||
  'invalid-credential' ||
  'user-disabled' => AuthErrorCode.wrongCredentials,
  'email-already-in-use' ||
  'account-exists-with-different-credential' => AuthErrorCode.emailInUse,
  'weak-password' => AuthErrorCode.weakPassword,
  'network-request-failed' => AuthErrorCode.network,
  'too-many-requests' => AuthErrorCode.tooManyRequests,
  'popup-closed-by-user' ||
  'cancelled-popup-request' ||
  'web-context-canceled' ||
  'canceled' => AuthErrorCode.cancelled,
  _ => AuthErrorCode.unknown,
};

/// Firebase Authentication: email + пароль и Google.
///
/// Гостевой режим остаётся локальным (флаг в SharedPreferences), поэтому
/// приложение можно открыть и без интернета.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._prefs) {
    _subscription = _auth.authStateChanges().listen((user) {
      // Вошёл в аккаунт — гостевой режим больше не нужен.
      if (user != null) _prefs.remove(LocalAuthRepository.guestKey);
      _controller.add(currentUser);
    });
  }

  final FirebaseAuth _auth;
  final SharedPreferences _prefs;
  final _controller = StreamController<AppUser?>.broadcast();
  late final StreamSubscription<User?> _subscription;

  bool get _isGuest => _prefs.getBool(LocalAuthRepository.guestKey) ?? false;

  static AppUser _map(User user) => AppUser(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user != null) return _map(user);
    return _isGuest ? const AppUser.guest() : null;
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield currentUser;
    yield* _controller.stream;
  }

  @override
  bool get supportsAccounts => true;

  /// Выполняет действие Firebase и переводит его ошибки в [AuthFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(mapFirebaseAuthError(e.code), e.message);
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      _controller.add(currentUser);
    }
  });

  /// Вход через Google средствами самого Firebase Auth:
  /// в браузере — всплывающее окно, на телефоне — системный браузер
  /// (Custom Tabs / SFSafariViewController). Отдельный пакет google_sign_in
  /// не нужен.
  @override
  Future<void> signInWithGoogle() => _guard(() {
    final provider = GoogleAuthProvider()..addScope('email');
    return kIsWeb
        ? _auth.signInWithPopup(provider)
        : _auth.signInWithProvider(provider);
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> continueAsGuest() async {
    await _prefs.setBool(LocalAuthRepository.guestKey, true);
    _controller.add(currentUser);
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(LocalAuthRepository.guestKey);
    await _auth.signOut();
    _controller.add(currentUser);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
