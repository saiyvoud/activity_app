import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatPrice ໃສ່ຈຸດຂັ້ນ', () {
    expect(formatPrice(500000), '500,000');
    expect(formatPrice(0), '0');
  });

  test('Product.fromMap ຮອງຮັບ field ຫຼາຍແບບ', () {
    final p = Product.fromMap('p1', {
      'name': 'Run',
      'price': '350,000',
      'category_id': 'cat_sport',
      'description': 'detail',
    });
    expect(p.title, 'Run');
    expect(p.price, 350000);
    expect(p.categoryId, 'cat_sport');
    expect(p.detail, 'detail');
  });

  test('CategoryItem.fromMap ອ່ານ category_name ເກົ່າໄດ້', () {
    final c = CategoryItem.fromMap('c1', {'category_name': 'Sports'});
    expect(c.name, 'Sports');
  });

  test('PurchaseOrder ແປງໄປ-ກັບ Map', () {
    final item = CartItem.fromMap('p1', {
      'productId': 'p1', 'title': 'A', 'price': 1000, 'qty': 3,
    });
    final o = PurchaseOrder(
      id: 'o1', billNo: 'INV-1', items: [item], subtotal: 3000, fee: 0,
      total: 3000, paymentMethod: 'BCEL One', status: 'paid',
      customerName: 'N', customerEmail: 'e', customerPhone: '',
      ticketCodes: const ['TK-1', 'TK-2', 'TK-3'], createdAt: DateTime(2026),
    );
    final back = PurchaseOrder.fromMap('o1', o.toMap());
    expect(back.itemCount, 3);
    expect(back.total, 3000);
    expect(back.ticketCodes.length, 3);
  });
}
