import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Состояние авторизации.
class AuthState extends Equatable {
  const AuthState({this.user, this.busy = false, this.error});

  /// `null` — пользователь не вошёл.
  final AppUser? user;

  /// Идёт запрос (кнопки блокируются, показывается индикатор).
  final bool busy;

  /// Ошибка последнего действия.
  final AuthErrorCode? error;

  bool get isSignedIn => user != null;

  @override
  List<Object?> get props => [user, busy, error];
}

/// Вход, регистрация и выход. Текущий пользователь приходит из потока
/// репозитория, а методы только запускают действие и показывают ошибку.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      super(AuthState(user: repository.currentUser)) {
    _subscription = repository.authStateChanges().listen(
      (user) => emit(AuthState(user: user)),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  bool get supportsAccounts => _repository.supportsAccounts;

  Future<bool> _run(Future<void> Function() action) async {
    emit(AuthState(user: state.user, busy: true));
    try {
      await action();
      emit(AuthState(user: _repository.currentUser));
      return true;
    } on AuthFailure catch (e) {
      emit(AuthState(user: state.user, error: e.code));
      return false;
    }
  }

  Future<bool> signIn(String email, String password) =>
      _run(() => _repository.signInWithEmail(email.trim(), password));

  Future<bool> register(String email, String password, {String? name}) => _run(
    () => _repository.registerWithEmail(
      email.trim(),
      password,
      displayName: name?.trim(),
    ),
  );

  Future<bool> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _repository.sendPasswordReset(email.trim()));

  Future<bool> continueAsGuest() => _run(_repository.continueAsGuest);

  Future<void> signOut() => _run(_repository.signOut);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
