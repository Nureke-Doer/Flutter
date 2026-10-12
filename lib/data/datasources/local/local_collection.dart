import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// Запись коллекции вместе со служебными полями синхронизации.
///
/// - [updatedAt] — время последнего изменения: при синхронизации
///   с облаком (неделя 8) побеждает более новая версия;
/// - [deleted] — «надгробие» (tombstone): удалённая запись не стирается
///   сразу, чтобы удаление тоже можно было передать на другие устройства.
class SyncRecord {
  const SyncRecord({
    required this.id,
    required this.updatedAt,
    this.data,
    this.deleted = false,
  });

  final String id;
  final Map<String, dynamic>? data;
  final DateTime updatedAt;
  final bool deleted;

  Map<String, dynamic> toJson() => {
    'u': updatedAt.toUtc().toIso8601String(),
    'd': deleted,
    if (data != null) 'v': data,
  };

  /// Разбирает строку из Hive. Повреждённая запись → `null`.
  static SyncRecord? tryParse(String id, String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SyncRecord(
        id: id,
        updatedAt: DateTime.parse(json['u'] as String),
        deleted: json['d'] as bool? ?? false,
        data: (json['v'] as Map?)?.cast<String, dynamic>(),
      );
    } on Object {
      return null;
    }
  }
}

/// Коллекция JSON-документов в одной коробке Hive: `id → SyncRecord`.
///
/// Общая основа для всех локальных репозиториев (привычки, отметки,
/// категории, цели…), чтобы не повторять один и тот же код.
/// Значения — JSON-строки, поэтому TypeAdapter-ы Hive не нужны.
class LocalCollection {
  LocalCollection(this.name, this._box, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Имя коллекции (совпадает с именем коллекции в Firestore).
  final String name;
  final Box<String> _box;
  final DateTime Function() _clock;

  /// Изменения, сделанные в приложении (не пришедшие из облака).
  /// На них подписывается сервис синхронизации.
  final _localChanges = StreamController<SyncRecord>.broadcast();

  Stream<SyncRecord> get localChanges => _localChanges.stream;

  /// Все записи, включая удалённые («надгробия»).
  Iterable<SyncRecord> records() sync* {
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final record = SyncRecord.tryParse(key as String, raw);
      if (record != null) yield record;
    }
  }

  /// Данные всех не удалённых записей.
  List<Map<String, dynamic>> readAll() => [
    for (final r in records())
      if (!r.deleted && r.data != null) r.data!,
  ];

  Map<String, dynamic>? read(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    final record = SyncRecord.tryParse(id, raw);
    return record == null || record.deleted ? null : record.data;
  }

  /// Сразу отдаёт текущие данные, затем — новые после каждого изменения.
  Stream<List<Map<String, dynamic>>> watch() async* {
    yield readAll();
    yield* _box.watch().map((_) => readAll());
  }

  Future<void> put(String id, Map<String, dynamic> data) =>
      _write(SyncRecord(id: id, data: data, updatedAt: _clock()));

  /// Записывает несколько документов одной операцией (одно событие watch).
  Future<void> putAll(Map<String, Map<String, dynamic>> items) async {
    final now = _clock();
    final written = [
      for (final e in items.entries)
        SyncRecord(id: e.key, data: e.value, updatedAt: now),
    ];
    await _box.putAll({for (final r in written) r.id: jsonEncode(r.toJson())});
    written.forEach(_localChanges.add);
  }

  /// Помечает запись удалённой.
  Future<void> delete(String id) =>
      _write(SyncRecord(id: id, updatedAt: _clock(), deleted: true));

  /// Удаляет все записи, для которых [test] вернул `true`.
  Future<void> deleteWhere(
    bool Function(Map<String, dynamic> data) test,
  ) async {
    final now = _clock();
    final tombstones = [
      for (final r in records())
        if (!r.deleted && r.data != null && test(r.data!))
          SyncRecord(id: r.id, updatedAt: now, deleted: true),
    ];
    if (tombstones.isEmpty) return;
    await _box.putAll({
      for (final r in tombstones) r.id: jsonEncode(r.toJson()),
    });
    tombstones.forEach(_localChanges.add);
  }

  /// Применяет запись из облака, если она новее локальной.
  /// Возвращает `true`, если локальные данные изменились.
  Future<bool> applyRemote(SyncRecord remote) async {
    final raw = _box.get(remote.id);
    final local = raw == null ? null : SyncRecord.tryParse(remote.id, raw);
    if (local != null && !remote.updatedAt.isAfter(local.updatedAt)) {
      return false;
    }
    await _box.put(remote.id, jsonEncode(remote.toJson()));
    return true;
  }

  Future<void> _write(SyncRecord record) async {
    await _box.put(record.id, jsonEncode(record.toJson()));
    _localChanges.add(record);
  }

  /// Полностью очищает коллекцию (например, при выходе из аккаунта).
  Future<void> clear() => _box.clear();
}
