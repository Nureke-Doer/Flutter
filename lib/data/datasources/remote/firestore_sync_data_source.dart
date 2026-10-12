import 'package:cloud_firestore/cloud_firestore.dart';

import '../local/local_collection.dart';
import 'sync_remote_data_source.dart';

/// Cloud Firestore: `users/{uid}/{collection}/{id}`.
///
/// Документ: `{v: данные, u: время изменения (мс, UTC), d: удалён}`.
/// Security Rules (`firestore.rules`) разрешают доступ только к своему
/// `users/{uid}`.
class FirestoreSyncDataSource implements SyncRemoteDataSource {
  FirestoreSyncDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _ref(String uid, String name) =>
      _db.collection('users').doc(uid).collection(name);

  static Map<String, dynamic> _toDoc(SyncRecord r) => {
    'u': r.updatedAt.toUtc().millisecondsSinceEpoch,
    'd': r.deleted,
    if (r.data != null) 'v': r.data,
  };

  static SyncRecord? _fromDoc(String id, Map<String, dynamic>? doc) {
    if (doc == null || doc['u'] is! int) return null;
    return SyncRecord(
      id: id,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        doc['u'] as int,
        isUtc: true,
      ),
      deleted: doc['d'] as bool? ?? false,
      data: (doc['v'] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  Future<List<SyncRecord>> fetchAll(String uid, String collection) async {
    final snapshot = await _ref(uid, collection).get();
    return [for (final doc in snapshot.docs) ?_fromDoc(doc.id, doc.data())];
  }

  @override
  Stream<List<SyncRecord>> watch(String uid, String collection) =>
      _ref(uid, collection).snapshots().map(
        (snapshot) => [
          // Только изменённые документы, а не вся коллекция каждый раз.
          for (final change in snapshot.docChanges)
            if (change.type != DocumentChangeType.removed)
              ?_fromDoc(change.doc.id, change.doc.data()),
        ],
      );

  @override
  Future<void> putAll(
    String uid,
    String collection,
    List<SyncRecord> records,
  ) async {
    // В одном batch не больше 500 операций.
    for (var i = 0; i < records.length; i += 450) {
      final batch = _db.batch();
      for (final r in records.skip(i).take(450)) {
        batch.set(_ref(uid, collection).doc(r.id), _toDoc(r));
      }
      await batch.commit();
    }
  }
}
