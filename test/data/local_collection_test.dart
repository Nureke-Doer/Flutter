import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/data/datasources/local/hive_storage.dart';
import 'package:habit_study_tracker/data/datasources/local/local_collection.dart';

import '../helpers/hive_test_utils.dart';

void main() {
  var now = DateTime.utc(2026, 9, 9, 12);
  late LocalCollection collection;

  setUp(() async {
    await setUpTestHive();
    now = DateTime.utc(2026, 9, 9, 12);
    collection = testCollection(HiveBoxes.categories, clock: () => now);
  });

  tearDown(tearDownTestHive);

  test('put / read / delete с «надгробием»', () async {
    await collection.put('a', {'name': 'A'});
    expect(collection.read('a'), {'name': 'A'});

    await collection.delete('a');
    expect(collection.read('a'), isNull);
    expect(collection.readAll(), isEmpty);
    // Запись осталась как удалённая — чтобы передать удаление в облако.
    expect(collection.records().single.deleted, isTrue);
  });

  test('localChanges сообщает о локальных изменениях', () async {
    final changes = <String>[];
    final sub = collection.localChanges.listen(
      (r) => changes.add('${r.id}:${r.deleted}'),
    );
    await collection.put('a', {'x': 1});
    await collection.putAll({
      'b': {'x': 2},
    });
    await collection.deleteWhere((json) => json['x'] == 2);
    await Future<void>.delayed(Duration.zero);
    expect(changes, ['a:false', 'b:false', 'b:true']);
    await sub.cancel();
  });

  test('applyRemote применяет только более новую версию', () async {
    await collection.put('a', {'v': 'local'});

    final older = SyncRecord(
      id: 'a',
      data: {'v': 'old'},
      updatedAt: now.subtract(const Duration(minutes: 1)),
    );
    expect(await collection.applyRemote(older), isFalse);
    expect(collection.read('a'), {'v': 'local'});

    final newer = SyncRecord(
      id: 'a',
      data: {'v': 'remote'},
      updatedAt: now.add(const Duration(minutes: 1)),
    );
    expect(await collection.applyRemote(newer), isTrue);
    expect(collection.read('a'), {'v': 'remote'});
  });

  test('повреждённая запись пропускается', () async {
    await hiveBox(HiveBoxes.categories).put('bad', '{oops');
    await collection.put('ok', {'v': 1});
    expect(collection.readAll(), [
      {'v': 1},
    ]);
  });
}
