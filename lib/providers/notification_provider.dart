import 'package:activity/core/db.dart';
import 'package:activity/core/models.dart';
import 'package:activity/providers/user_bound_provider.dart';
import 'package:firebase_database/firebase_database.dart';

/// ແຈ້ງເຕືອນ: notifications/{uid}/{id}
class NotificationProvider extends UserBoundProvider {
  List<AppNotification> _items = [];
  List<AppNotification> get items => _items;

  int get unreadCount => _items.where((n) => !n.read).length;

  @override
  Query buildQuery(String uid) => Db.ref('notifications/$uid');

  @override
  void onSnapshot(DataSnapshot snapshot) {
    _items = snapshot.children
        .where((c) => c.value is Map)
        .map((c) => AppNotification.fromMap(c.key!, asMap(c.value)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void clear() => _items = [];

  Future<void> markRead(AppNotification n) async {
    if (uid == null || n.read) return;
    await Db.ref('notifications/$uid/${n.id}').update({'read': true});
  }

  Future<void> markAllRead() async {
    if (uid == null) return;
    final updates = <String, Object?>{
      for (final n in _items.where((n) => !n.read))
        'notifications/$uid/${n.id}/read': true,
    };
    if (updates.isNotEmpty) await Db.ref().update(updates);
  }

  Future<void> delete(AppNotification n) async {
    if (uid == null) return;
    await Db.ref('notifications/$uid/${n.id}').remove();
  }

  Future<void> clearAll() async {
    if (uid == null) return;
    await Db.ref('notifications/$uid').remove();
  }
}
