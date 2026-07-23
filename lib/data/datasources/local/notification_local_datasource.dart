import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../models/notification_model.dart';

/// Pure Hive — notification history is device-local only (phases.md §5).
class NotificationLocalDatasource {
  final Box _box;
  final _controller = StreamController<List<NotificationModel>>.broadcast();

  NotificationLocalDatasource({required Box box}) : _box = box;

  Stream<List<NotificationModel>> watchNotifications() async* {
    yield _read();
    yield* _controller.stream;
  }

  /// New notifications go to the front — newest first, matching every
  /// other list/history screen in this app.
  Future<void> addNotification(NotificationModel notification) async {
    final list = _read()..insert(0, notification);
    await _save(list);
  }

  Future<void> markAsRead(String id) async {
    final list = _read();
    final idx = list.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(isRead: true);
    await _save(list);
  }

  Future<void> markAllAsRead() async {
    final list = _read().map((n) => n.copyWith(isRead: true)).toList();
    await _save(list);
  }

  List<NotificationModel> _read() {
    final List<dynamic> raw = _box.get(HiveKeys.notificationItems, defaultValue: []);
    return raw.map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _save(List<NotificationModel> list) async {
    await _box.put(HiveKeys.notificationItems, list.map((n) => n.toJson()).toList());
    _controller.add(list);
  }
}
