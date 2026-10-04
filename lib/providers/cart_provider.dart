import 'package:activity/core/db.dart';
import 'package:activity/core/models.dart';
import 'package:activity/providers/user_bound_provider.dart';
import 'package:firebase_database/firebase_database.dart';

/// ກະຕ່າຂອງຂ້ອຍ: carts/{uid}/{productId}
class CartProvider extends UserBoundProvider {
  static const int maxQty = 10;

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  int get count => _items.fold(0, (s, i) => s + i.qty);
  int get total => _items.fold(0, (s, i) => s + i.subtotal);
  bool get isEmpty => _items.isEmpty;

  int qtyOf(String productId) =>
      _items.where((i) => i.productId == productId).firstOrNull?.qty ?? 0;

  DatabaseReference _ref([String? productId]) =>
      Db.ref(productId == null ? 'carts/$uid' : 'carts/$uid/$productId');

  @override
  Query buildQuery(String uid) => Db.ref('carts/$uid');

  @override
  void onSnapshot(DataSnapshot snapshot) {
    _items = snapshot.children
        .where((c) => c.value is Map)
        .map((c) => CartItem.fromMap(c.key!, asMap(c.value)))
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  @override
  void clear() => _items = [];

  /// ເພີ່ມສິນຄ້າເຂົ້າກະຕ່າ. ຄືນ false ຖ້າເກີນຈຳນວນສູງສຸດ
  Future<bool> add(Product p, {int qty = 1}) async {
    if (uid == null) return false;
    final current = qtyOf(p.id);
    final next = current + qty;
    if (next > maxQty) return false;
    if (current == 0) {
      await _ref(p.id).set(CartItem.fromProduct(p, qty).toMap());
    } else {
      await _ref(p.id).update({'qty': next, 'price': p.price});
    }
    return true;
  }

  Future<void> setQty(String productId, int qty) async {
    if (uid == null) return;
    if (qty <= 0) return remove(productId);
    await _ref(productId).update({'qty': qty.clamp(1, maxQty)});
  }

  Future<void> remove(String productId) async {
    if (uid == null) return;
    await _ref(productId).remove();
  }

  Future<void> clearCart() async {
    if (uid == null) return;
    await _ref().remove();
  }
}
