import 'dart:math';

import 'package:activity/core/db.dart';
import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/providers/user_bound_provider.dart';
import 'package:firebase_database/firebase_database.dart';

/// ບິນ ແລະ ປະຫວັດການຊື້: orders/{uid}/{orderId}
class OrderProvider extends UserBoundProvider {
  final Random _rand = Random();

  List<PurchaseOrder> _orders = [];
  List<PurchaseOrder> get orders => _orders;

  int get totalSpent => _orders.fold(0, (s, o) => s + o.total);

  PurchaseOrder? byId(String id) => _orders.where((o) => o.id == id).firstOrNull;

  @override
  Query buildQuery(String uid) => Db.ref('orders/$uid');

  @override
  void onSnapshot(DataSnapshot snapshot) {
    _orders = snapshot.children
        .where((c) => c.value is Map)
        .map((c) => PurchaseOrder.fromMap(c.key!, asMap(c.value)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void clear() => _orders = [];

  String _randomCode(int len) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(len, (_) => chars[_rand.nextInt(chars.length)]).join();
  }

  /// ຊຳລະເງິນ: ສ້າງບິນ + ບັດ + ແຈ້ງເຕືອນ ແລະ ລ້າງກະຕ່າ ໃນຄັ້ງດຽວ (multi-path update)
  Future<PurchaseOrder> checkout({
    required AppUser customer,
    required List<CartItem> items,
    required String paymentMethod,
    int fee = 0,
  }) async {
    final uid = this.uid;
    if (uid == null) throw StateError('ກະລຸນາເຂົ້າສູ່ລະບົບ');
    if (items.isEmpty) throw StateError('ກະຕ່າວ່າງ');

    final now = DateTime.now();
    final orderId = Db.newKey('orders/$uid');
    final billNo =
        'INV-${now.year}${two(now.month)}${two(now.day)}-${_randomCode(5)}';

    final updates = <String, Object?>{};
    final codes = <String>[];
    for (final item in items) {
      for (var i = 0; i < item.qty; i++) {
        final code = 'TK-${_randomCode(8)}';
        codes.add(code);
        updates['tickets/$uid/$code'] = Ticket(
          code: code,
          orderId: orderId,
          billNo: billNo,
          productId: item.productId,
          title: item.title,
          image: item.image,
          date: item.date,
          time: item.time,
          address: item.address,
          price: item.price,
          paymentMethod: paymentMethod,
          status: TicketStatus.active,
          purchasedAt: now,
        ).toMap();
      }
    }

    final subtotal = items.fold<int>(0, (s, i) => s + i.subtotal);
    final order = PurchaseOrder(
      id: orderId,
      billNo: billNo,
      items: items,
      subtotal: subtotal,
      fee: fee,
      total: subtotal + fee,
      paymentMethod: paymentMethod,
      status: 'paid',
      customerName: customer.name,
      customerEmail: customer.email,
      customerPhone: customer.phone,
      ticketCodes: codes,
      createdAt: now,
    );

    updates['orders/$uid/$orderId'] = order.toMap();
    updates['carts/$uid'] = null; // ລ້າງກະຕ່າ

    final n1 = Db.newKey('notifications/$uid');
    updates['notifications/$uid/$n1'] = Db.notificationData(
      title: 'ຊື້ບັດສຳເລັດ',
      body:
          'ບິນ $billNo: ${order.itemCount} ໃບ, ລວມ ${formatPrice(order.total)} ກີບ ຜ່ານ $paymentMethod',
      type: 'purchase',
    );
    for (final item in items) {
      final nid = Db.newKey('notifications/$uid');
      updates['notifications/$uid/$nid'] = Db.notificationData(
        title: 'ແຈ້ງເຕືອນກິດຈະກຳ',
        body:
            'ຢ່າລືມ! "${item.title}" ວັນທີ ${item.date} ເວລາ ${item.time} ທີ່ ${item.address}',
        type: 'reminder',
      );
    }

    await Db.ref().update(updates);
    return order;
  }
}
