import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/datasources/local/local_collection.dart';
import 'package:habit_study_tracker/data/datasources/remote/sync_remote_data_source.dart';
import 'package:habit_study_tracker/data/sync/sync_service.dart';
import 'package:habit_study_tracker/domain/entities/app_user.dart';

import '../helpers/hive_test_utils.dart' show setUpTestHive, tearDownTestHive;

/// «Облако» в памяти: users/{uid}/{collection}/{id}.
class InMemoryRemote implements SyncRemoteDataSource {
  final data = <String, Map<String, SyncRecord>>{};
  final _controllers = <String, StreamController<List<SyncRecord>>>{};
  bool offline = false;

  String _key(String uid, String c) => '$uid/$c';

  StreamController<List<SyncRecord>> _controller(String key) =>
      _controllers.putIfAbsent(key, StreamController.broadcast);

  @override
  Future<List<SyncRecord>> fetchAll(String uid, String collection) async {
    if (offline) throw Exception('offline');
    return data[_key(uid, collection)]?.values.toList() ?? [];
  }

  @override
  Stream<List<SyncRecord>> watch(String uid, String collection) =>
      _controller(_key(uid, collection)).stream;

  @override
  Future<void> putAll(
    String uid,
    String collection,
    List<SyncRecord> records,
  ) async {
    if (offline) throw Exception('offline');
    final map = data.putIfAbsent(_key(uid, collection), () => {});
    for (final r in records) {
      map[r.id] = r;
    }
  }

  /// Изменение «с другого устройства».
  void pushFromOtherDevice(String uid, String collection, SyncRecord r) {
    data.putIfAbsent(_key(uid, collection), () => {})[r.id] = r;
    _controller(_key(uid, collection)).add([r]);
  }
}

void main() {
  late LocalCollection habits;
  late InMemoryRemote remote;
  late SyncService sync;
  var now = DateTime.utc(2026, 9, 9, 10);

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  setUp(() async {
    await setUpTestHive();
    now = DateTime.utc(2026, 9, 9, 10);
    // Имя коллекции как в приложении (в Firestore — users/{uid}/habits).
    habits = LocalCollection(
      'habits',
      hiveBox(HiveBoxes.habits),
      clock: () => now,
    );
    remote = InMemoryRemote();
    sync = SyncService(
      collections: [habits],
      remote: remote,
      meta: hiveBox(HiveBoxes.meta),
    );
  });

  tearDown(() async {
    await sync.stop();
    await tearDownTestHive();
  });

  test('данные гостя выгружаются в аккаунт при первом входе', () async {
    await habits.put('a', {'title': 'Чтение'});
    await sync.start('u1');
    expect(remote.data['u1/habits']!['a']!.data, {'title': 'Чтение'});
    expect(sync.status.value, SyncStatus.synced);
  });

  test('данные из облака скачиваются на новое устройство', () async {
    remote.data['u1/habits'] = {
      'b': SyncRecord(id: 'b', data: {'title': 'Бег'}, updatedAt: now),
    };
    await sync.start('u1');
    expect(habits.read('b'), {'title': 'Бег'});
  });

  test(
    'локальные изменения сразу отправляются, удаление — «надгробием»',
    () async {
      await sync.start('u1');
      now = now.add(const Duration(minutes: 1));
      await habits.put('c', {'title': 'Вода'});
      await settle();
      expect(remote.data['u1/habits']!['c']!.data, {'title': 'Вода'});

      now = now.add(const Duration(minutes: 1));
      await habits.delete('c');
      await settle();
      expect(remote.data['u1/habits']!['c']!.deleted, isTrue);
    },
  );

  test('изменения с другого устройства применяются, если новее', () async {
    await habits.put('a', {'title': 'Старое'});
    await sync.start('u1');

    remote.pushFromOtherDevice(
      'u1',
      'habits',
      SyncRecord(
        id: 'a',
        data: {'title': 'Новое'},
        updatedAt: now.add(const Duration(hours: 1)),
      ),
    );
    await settle();
    expect(habits.read('a'), {'title': 'Новое'});

    // Более старая версия не перезаписывает локальную.
    remote.pushFromOtherDevice(
      'u1',
      'habits',
      SyncRecord(
        id: 'a',
        data: {'title': 'Устаревшее'},
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    );
    await settle();
    expect(habits.read('a'), {'title': 'Новое'});
  });

  test('конфликт: при входе побеждает более новая версия', () async {
    await habits.put('a', {'title': 'Локальная'}); // 10:00
    remote.data['u1/habits'] = {
      'a': SyncRecord(
        id: 'a',
        data: {'title': 'Облачная'},
        updatedAt: now.add(const Duration(minutes: 5)),
      ),
    };
    await sync.start('u1');
    expect(habits.read('a'), {'title': 'Облачная'});
  });

  test('вход в другой аккаунт очищает данные предыдущего', () async {
    await sync.start('u1');
    await habits.put('private', {'title': 'Чужое'});
    await settle();
    await sync.stop();

    await sync.start('u2');
    expect(habits.read('private'), isNull);
    expect(remote.data['u2/habits'], isNull);
  });

  test('без сети: статус error, данные остаются на устройстве', () async {
    remote.offline = true;
    await habits.put('a', {'title': 'Офлайн'});
    await sync.start('u1');
    expect(sync.status.value, SyncStatus.error);
    expect(habits.read('a'), {'title': 'Офлайн'});
  });

  test('bindTo: вход запускает синхронизацию, гость и выход — нет', () async {
    final users = StreamController<AppUser?>();
    final sub = sync.bindTo(users.stream);
    users.add(const AppUser.guest());
    await settle();
    expect(sync.uid, isNull);

    users.add(const AppUser(uid: 'u1'));
    await settle();
    expect(sync.uid, 'u1');

    users.add(null);
    await settle();
    expect(sync.uid, isNull);
    expect(sync.status.value, SyncStatus.localOnly);
    await sub.cancel();
    await users.close();
  });
}
