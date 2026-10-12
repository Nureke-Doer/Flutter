import 'package:equatable/equatable.dart';

/// Пользователь приложения.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });

  /// Гость: данные только на устройстве, без синхронизации.
  const AppUser.guest() : this(uid: 'guest', isGuest: true);

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isGuest];
}
