import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/firestore_date_parser.dart';
import '../../../domain/entities/broadcast_entity.dart';
import '../local/broadcast_local_datasource.dart';

/// Admin broadcasts in the shared `broadcasts` collection, so every
/// retailer's phone receives them. Falls back to the device-local Hive store
/// in simulation mode, same dual-mode pattern as the other datasources.
class BroadcastRemoteDatasource {
  FirebaseFirestore? _firestore;
  bool _useMock = false;
  final BroadcastLocalDatasource _local;

  BroadcastRemoteDatasource({
    FirebaseFirestore? firestore,
    required BroadcastLocalDatasource local,
  }) : _local = local {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      logWarning('BroadcastRemoteDatasource: Firestore unavailable, using simulation mode', e);
    }
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore!.collection(FirestorePaths.broadcasts);

  Stream<List<BroadcastEntity>> watchBroadcasts() {
    if (_useMock) return _local.watchBroadcasts();
    // ponytail: newest 50 only; page if the history ever needs to go further.
    return _collection
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return BroadcastEntity(
              id: d.id,
              title: data['title'] as String? ?? '',
              body: data['body'] as String? ?? '',
              sentAt: parseFirestoreDate(data['sentAt']),
            );
          }).toList(),
        );
  }

  Future<void> send({required String title, required String body}) async {
    if (_useMock) return _local.send(title: title, body: body);
    await _collection.add({
      'title': title,
      'body': body,
      'sentAt': DateTime.now(),
    });
  }
}
