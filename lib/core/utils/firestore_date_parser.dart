import 'package:cloud_firestore/cloud_firestore.dart';

/// Parses a `createdAt`-style field that may be a Firestore [Timestamp]
/// (when read from real Firestore) or a plain [DateTime] (when read back
/// from local Hive simulation storage, which cannot serialize [Timestamp]
/// directly — see the `firebase_mode.dart` dual-mode pattern).
DateTime parseFirestoreDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
