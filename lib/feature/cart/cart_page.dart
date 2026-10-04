import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/feature/cart/checkout_page.dart';
import 'package:activity/feature/product/product_detail_page.dart';
import 'package:activity/providers/cart_provider.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ກະຕ່າຂອງຂ້ອຍ: carts/{uid}
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _clear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ລ້າງກະຕ່າ?'),
        content: const Text('ລາຍການທັງໝົດໃນກະຕ່າຈະຖືກລຶບ'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ຍົກເລີກ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ລ້າງ'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<CartProvider>().clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    Widget body;
    if (cart.loading && cart.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (cart.error != null && cart.isEmpty) {
      body = ErrorView(error: cart.error!, onRetry: cart.refresh);
    } else if (cart.isEmpty) {
      body = EmptyView(
        icon: Icons.remove_shopping_cart_outlined,
        text: 'ກະຕ່າຂອງທ່ານຍັງວ່າງ',
        actionText: 'ໄປເລືອກກິດຈະກຳ',
        onAction: () => context.read<NavProvider>().setTab(NavProvider.home),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cart.items.length,
        itemBuilder: (context, i) => _CartTile(item: cart.items[i]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(cart.isEmpty ? 'ກະຕ່າຂອງຂ້ອຍ' : 'ກະຕ່າຂອງຂ້ອຍ (${cart.count})'),
        automaticallyImplyLeading: false,
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'ລ້າງກະຕ່າ',
              onPressed: () => _clear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ລວມ ${cart.count} ໃບ',
                              style: TextStyle(color: Colors.grey.shade600)),
                          Text('${formatPrice(cart.total)} ກີບ',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimary)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutPage()),
                        ),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('ສັ່ງຊື້'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Dismissible(
      key: ValueKey('cart-${item.productId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        cart.remove(item.productId);
        showSnack(context, 'ລຶບ "${item.title}" ອອກຈາກກະຕ່າແລ້ວ');
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: item.productId)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetImage(item.image, width: 80, height: 80),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('📅 ${item.date}  ⏰ ${item.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text('${formatPrice(item.subtotal)} ກີບ',
                              style: const TextStyle(
                                  color: kPrimary, fontWeight: FontWeight.bold)),
                        ),
                        QtyStepper(
                          qty: item.qty,
                          onMinus: () => cart.setQty(item.productId, item.qty - 1),
                          onPlus: item.qty < CartProvider.maxQty
                              ? () => cart.setQty(item.productId, item.qty + 1)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
