import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';

/// Low-level Firestore read/write helpers for user sync payloads.
class FirestoreSyncDataSource {
  FirestoreSyncDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid, String docId) {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection('data')
        .doc(docId);
  }

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    String collection,
  ) {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(collection);
  }

  Future<void> setDocument({
    required String uid,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _userDoc(uid, docId).set(
      {
        ...data,
        'syncedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getDocument({
    required String uid,
    required String docId,
  }) async {
    final snapshot = await _userDoc(uid, docId).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  Future<void> upsertCollectionItem({
    required String uid,
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _userCollection(uid, collection).doc(id).set(
      {
        ...data,
        'syncedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, Map<String, dynamic>>> getCollection({
    required String uid,
    required String collection,
  }) async {
    final snapshot = await _userCollection(uid, collection).get();
    return {
      for (final doc in snapshot.docs)
        doc.id: doc.data(),
    };
  }

  Future<void> setSyncMeta({
    required String uid,
    required Map<String, dynamic> meta,
  }) async {
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .set(
          {
            'syncMeta': meta,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }
}
