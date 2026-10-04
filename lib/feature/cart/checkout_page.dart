import 'package:activity/core/theme.dart';
import 'package:activity/feature/bill/bill_page.dart';
import 'package:activity/providers/auth_provider.dart';
import 'package:activity/providers/cart_provider.dart';
import 'package:activity/providers/order_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _PayMethod {
  final String name;
  final IconData icon;
  final Color color;
  const _PayMethod(this.name, this.icon, this.color);
}

const _methods = [
  _PayMethod('BCEL One', Icons.account_balance, Color(0xFFD32F2F)),
  _PayMethod('LDB Trust', Icons.account_balance_wallet, Color(0xFF1565C0)),
  _PayMethod('JDB Yes', Icons.qr_code_2, Color(0xFF2E7D32)),
  _PayMethod('ບັດເຄຣດິດ / ເດບິດ', Icons.credit_card, Color(0xFF6A1B9A)),
];

/// ຢືນຢັນການສັ່ງຊື້ ແລະ ຊຳລະເງິນ
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _method = 0;
  bool _loading = false;

  Future<void> _pay() async {
    final cart = context.read<CartProvider>();
    final user = context.read<AppAuthProvider>().profile;
    if (user == null || cart.isEmpty) return;
    final method = _methods[_method].name;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ຢືນຢັນການຊຳລະເງິນ'),
        content: Text(
            'ຈຳນວນ: ${cart.count} ໃບ\nຊຳລະຜ່ານ: $method\n\nລວມ: ${formatPrice(cart.total)} ກີບ'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ຍົກເລີກ')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ຢືນຢັນ')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final order = await context.read<OrderProvider>().checkout(
            customer: user,
            items: List.of(cart.items),
            paymentMethod: method,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BillPage(order: order, justPaid: true)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, 'ຊຳລະເງິນບໍ່ສຳເລັດ: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AppAuthProvider>().profile;

    if (cart.isEmpty && !_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('ສັ່ງຊື້')),
        body: const EmptyView(
            icon: Icons.remove_shopping_cart_outlined, text: 'ກະຕ່າວ່າງ'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ສັ່ງຊື້')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _title('ລາຍການ'),
          WhiteCard(
            child: Column(
              children: [
                for (final it in cart.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetImage(it.image, width: 48, height: 48),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${formatPrice(it.price)} × ${it.qty}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('${formatPrice(it.subtotal)} ກີບ',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _title('ຂໍ້ມູນຜູ້ຊື້'),
          WhiteCard(
            child: Column(
              children: [
                KeyValueRow('ຊື່', user?.name ?? '-'),
                KeyValueRow('ອີເມວ', user?.email ?? '-'),
                KeyValueRow('ເບີໂທ', (user?.phone ?? '').isEmpty ? '-' : user!.phone),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _title('ວິທີຊຳລະເງິນ'),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(_methods.length, (i) {
                final m = _methods[i];
                final selected = _method == i;
                return ListTile(
                  onTap: () => setState(() => _method = i),
                  leading: CircleAvatar(
                    backgroundColor: m.color.withValues(alpha: 0.12),
                    child: Icon(m.icon, color: m.color),
                  ),
                  title: Text(m.name),
                  trailing: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? kPrimary : Colors.grey,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _title('ສະຫຼຸບ'),
          WhiteCard(
            child: Column(
              children: [
                KeyValueRow('ຈຳນວນບັດ', '${cart.count} ໃບ'),
                KeyValueRow('ລາຄາລວມ', '${formatPrice(cart.total)} ກີບ'),
                const KeyValueRow('ຄ່າທຳນຽມ', '0 ກີບ'),
                const Divider(),
                KeyValueRow('ລວມທັງໝົດ', '${formatPrice(cart.total)} ກີບ',
                    bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LoadingButton(
            loading: _loading,
            onPressed: _pay,
            child: Text('ຊຳລະເງິນ ${formatPrice(cart.total)} ກີບ'),
          ),
        ),
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      );
}
