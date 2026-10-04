import 'package:activity/core/db.dart';
import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/providers/user_bound_provider.dart';
import 'package:firebase_database/firebase_database.dart';

/// ບັດຂອງຂ້ອຍ: tickets/{uid}/{code}
class TicketProvider extends UserBoundProvider {
  List<Ticket> _tickets = [];
  List<Ticket> get tickets => _tickets;

  List<Ticket> get active => _tickets.where((t) => !t.isUsed).toList();

  List<Ticket> get used => _tickets.where((t) => t.isUsed).toList()
    ..sort((a, b) => (b.usedAt ?? b.purchasedAt)
        .compareTo(a.usedAt ?? a.purchasedAt));

  List<Ticket> byOrder(String orderId) =>
      _tickets.where((t) => t.orderId == orderId).toList();

  Ticket? byCode(String code) => _tickets.where((t) => t.code == code).firstOrNull;

  @override
  Query buildQuery(String uid) => Db.ref('tickets/$uid');

  @override
  void onSnapshot(DataSnapshot snapshot) {
    _tickets = snapshot.children
        .where((c) => c.value is Map)
        .map((c) => Ticket.fromMap(c.key!, asMap(c.value)))
        .toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
  }

  @override
  void clear() => _tickets = [];

  Future<void> useTicket(Ticket t) async {
    final uid = this.uid;
    if (uid == null || t.isUsed) return;
    final now = DateTime.now();
    final nid = Db.newKey('notifications/$uid');
    await Db.ref().update({
      'tickets/$uid/${t.code}/status': 'used',
      'tickets/$uid/${t.code}/usedAt': now.millisecondsSinceEpoch,
      'notifications/$uid/$nid': Db.notificationData(
        title: 'ນຳໃຊ້ບັດແລ້ວ',
        body:
            'ບັດ ${t.code} ຂອງ "${t.title}" ຖືກນຳໃຊ້ເມື່ອ ${formatDateTime(now)}',
        type: 'used',
      ),
    });
  }
}
