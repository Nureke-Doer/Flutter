import '../local/local_collection.dart';

/// Удалённое хранилище для синхронизации коллекций пользователя.
///
/// Интерфейс отделяет [SyncService] от Firestore: в приложении работает
/// `FirestoreSyncDataSource`, а в тестах — реализация в памяти.
abstract interface class SyncRemoteDataSource {
  /// Все записи коллекции пользователя (включая удалённые).
  Future<List<SyncRecord>> fetchAll(String uid, String collection);

  /// Изменения коллекции, пришедшие с сервера (с других устройств).
  Stream<List<SyncRecord>> watch(String uid, String collection);

  /// Записывает несколько записей.
  Future<void> putAll(String uid, String collection, List<SyncRecord> records);
}
