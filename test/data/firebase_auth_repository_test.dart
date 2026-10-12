import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/repositories/firebase_auth_repository.dart';
import 'package:habit_study_tracker/data/repositories/local_auth_repository.dart';
import 'package:habit_study_tracker/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth auth;
  late StreamController<User?> changes;
  late SharedPreferences prefs;
  late FirebaseAuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    auth = MockFirebaseAuth();
    changes = StreamController<User?>.broadcast();
    when(() => auth.authStateChanges()).thenAnswer((_) => changes.stream);
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.signOut()).thenAnswer((_) async {});
    repository = FirebaseAuthRepository(auth, prefs);
  });

  tearDown(() async {
    await repository.dispose();
    await changes.close();
  });

  test('коды ошибок Firebase переводятся в доменные', () {
    expect(mapFirebaseAuthError('invalid-email'), AuthErrorCode.invalidEmail);
    expect(
      mapFirebaseAuthError('invalid-credential'),
      AuthErrorCode.wrongCredentials,
    );
    expect(
      mapFirebaseAuthError('email-already-in-use'),
      AuthErrorCode.emailInUse,
    );
    expect(mapFirebaseAuthError('weak-password'), AuthErrorCode.weakPassword);
    expect(
      mapFirebaseAuthError('network-request-failed'),
      AuthErrorCode.network,
    );
    expect(mapFirebaseAuthError('что-то новое'), AuthErrorCode.unknown);
  });

  test('вход по email: ошибка Firebase → AuthFailure', () async {
    when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    await expectLater(
      repository.signInWithEmail('a@b.c', '123456'),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.code,
          'code',
          AuthErrorCode.wrongCredentials,
        ),
      ),
    );
  });

  test('пользователь Firebase отображается в AppUser', () async {
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('a@b.c');
    when(() => user.displayName).thenReturn('Нурым');
    when(() => user.photoURL).thenReturn(null);
    when(() => auth.currentUser).thenReturn(user);

    expect(repository.currentUser?.uid, 'u1');
    expect(repository.currentUser?.displayName, 'Нурым');
    expect(repository.currentUser?.isGuest, isFalse);
  });

  test('гость → вход в аккаунт сбрасывает гостевой флаг', () async {
    await repository.continueAsGuest();
    expect(repository.currentUser?.isGuest, isTrue);

    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('a@b.c');
    when(() => user.displayName).thenReturn(null);
    when(() => user.photoURL).thenReturn(null);
    when(() => auth.currentUser).thenReturn(user);
    changes.add(user);
    await Future<void>.delayed(Duration.zero);

    expect(prefs.getBool(LocalAuthRepository.guestKey), isNull);
    expect(repository.currentUser?.uid, 'u1');
  });

  test('регистрация сохраняет имя пользователя', () async {
    final user = MockUser();
    final credential = MockUserCredential();
    when(() => credential.user).thenReturn(user);
    when(() => user.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => user.reload()).thenAnswer((_) async {});
    when(
      () => auth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credential);

    await repository.registerWithEmail(
      'a@b.c',
      'secret1',
      displayName: 'Нурым',
    );
    verify(() => user.updateDisplayName('Нурым')).called(1);
  });

  test('выход: сброс гостя и signOut в Firebase', () async {
    await repository.continueAsGuest();
    await repository.signOut();
    expect(repository.currentUser, isNull);
    verify(() => auth.signOut()).called(1);
  });
}
