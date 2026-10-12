import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../../domain/entities/app_user.dart';
import '../datasources/local/local_collection.dart';
import '../datasources/remote/sync_remote_data_source.dart';

/// Состояние синхронизации (показывается в профиле).
enum SyncStatus {
  /// Гость или облако не настроено — данные только на устройстве.
  localOnly,
  syncing,
  synced,

  /// Сервер недоступен: изменения сохранены локально и отправятся позже.
  error,
}

/// Синхронизация локальных коллекций Hive с облаком (offline-first).
///
/// - Источник правды — Hive: экраны всегда читают локальные данные
///   и работают без интернета.
/// - При входе в аккаунт: скачиваем записи с сервера, применяем более
///   новые; отправляем на сервер локальные записи, которых там нет или
///   которые новее; затем слушаем изменения в обе стороны.
/// - Конфликт решается по времени изменения (`updatedAt`):
///   побеждает более новая запись («last write wins»).
/// - Удаление передаётся «надгробием» (`deleted: true`).
/// - Если на устройстве были данные другого аккаунта — они очищаются,
///   а данные гостя переносятся в аккаунт.
class SyncService {
  SyncService({
    required List<LocalCollection> collections,
    required SyncRemoteDataSource remote,
    required Box<String> meta,
  }) : _collections = collections,
       _remote = remote,
       _meta = meta;

  static const ownerKey = 'sync.owner';

  final List<LocalCollection> _collections;
  final SyncRemoteDataSource _remote;
  final Box<String> _meta;
  final _subscriptions = <StreamSubscription<Object?>>[];
  String? _uid;

  final status = ValueNotifier(SyncStatus.localOnly);

  String? get uid => _uid;

  /// Запускает/останавливает синхронизацию вслед за входом и выходом.
  StreamSubscription<AppUser?> bindTo(Stream<AppUser?> users) =>
      users.listen((user) {
        if (user == null || user.isGuest) {
          stop();
        } else if (user.uid != _uid) {
          start(user.uid);
        }
      });

  Future<void> start(String uid) async {
    await stop();
    _uid = uid;
    status.value = SyncStatus.syncing;

    final owner = _meta.get(ownerKey);
    if (owner != null && owner != uid) {
      // Данные другого аккаунта не должны попасть в этот.
      for (final c in _collections) {
        await c.clear();
      }
    }
    await _meta.put(ownerKey, uid);

    var ok = true;
    for (final collection in _collections) {
      try {
        await _initialSync(uid, collection);
      } on Object catch (e) {
        debugPrint('Sync ${collection.name}: $e');
        ok = false;
      }
      if (_uid != uid) return; // за это время пользователь вышел
      _subscriptions
        ..add(
          _remote.watch(uid, collection.name).listen((records) async {
            for (final r in records) {
              await collection.applyRemote(r);
            }
          }, onError: (Object e) => status.value = SyncStatus.error),
        )
        ..add(
          collection.localChanges.listen((record) async {
            try {
              await _remote.putAll(uid, collection.name, [record]);
              status.value = SyncStatus.synced;
            } on Object {
              // Firestore сам повторит отправку, когда появится сеть.
              status.value = SyncStatus.error;
            }
          }),
        );
    }
    status.value = ok ? SyncStatus.synced : SyncStatus.error;
  }

  Future<void> _initialSync(String uid, LocalCollection collection) async {
    final remote = await _remote.fetchAll(uid, collection.name);
    final remoteById = {for (final r in remote) r.id: r};
    for (final r in remote) {
      await collection.applyRemote(r);
    }
    final toUpload = [
      for (final local in collection.records())
        if (remoteById[local.id] == null ||
            local.updatedAt.isAfter(remoteById[local.id]!.updatedAt))
          local,
    ];
    if (toUpload.isNotEmpty) {
      await _remote.putAll(uid, collection.name, toUpload);
    }
  }

  Future<void> stop() async {
    _uid = null;
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    status.value = SyncStatus.localOnly;
  }
}
