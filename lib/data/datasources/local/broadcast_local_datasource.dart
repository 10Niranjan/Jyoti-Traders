import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../domain/entities/broadcast_entity.dart';

/// Pure Hive, same `notifications_cache` box the per-device notification
/// history already opens at startup — one shared key, not uid-scoped (see
/// `BroadcastRepository`'s doc for why).
class BroadcastLocalDatasource {
  final Box _box;
  final _controller = StreamController<List<BroadcastEntity>>.broadcast();

  BroadcastLocalDatasource({required Box box}) : _box = box;

  Stream<List<BroadcastEntity>> watchBroadcasts() async* {
    yield _read();
    yield* _controller.stream;
  }

  Future<void> send({required String title, required String body}) async {
    final list = _read()
      ..insert(
        0,
        BroadcastEntity(id: const Uuid().v4(), title: title, body: body, sentAt: DateTime.now()),
      );
    await _box.put(
      HiveKeys.broadcastMessages,
      list
          .map(
            (b) => {
              'id': b.id,
              'title': b.title,
              'body': b.body,
              'sentAt': b.sentAt.toIso8601String(),
            },
          )
          .toList(),
    );
    _controller.add(list);
  }

  List<BroadcastEntity> _read() {
    final List<dynamic> raw = _box.get(HiveKeys.broadcastMessages, defaultValue: const []);
    return raw.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return BroadcastEntity(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        sentAt: DateTime.parse(map['sentAt'] as String),
      );
    }).toList();
  }
}
