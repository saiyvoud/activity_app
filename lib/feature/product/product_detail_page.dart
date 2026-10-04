import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/feature/product/product_widgets.dart';
import 'package:activity/providers/cart_provider.dart';
import 'package:activity/providers/catalog_providers.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ລາຍລະອຽດສິນຄ້າ (ອ່ານຈາກ ProductProvider ຈຶ່ງອັບເດດ realtime)
class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final product = context.select<ProductProvider, Product?>(
        (p) => p.byId(widget.productId));
    final inCart = context.select<CartProvider, int>((c) => c.qtyOf(widget.productId));

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(
            icon: Icons.search_off, text: 'ບໍ່ພົບກິດຈະກຳນີ້ ຫຼື ຖືກລຶບແລ້ວ'),
      );
    }
    final p = product;
    final maxAdd = CartProvider.maxQty - inCart;

    Future<void> add({required bool goCart}) async {
      if (maxAdd <= 0) {
        showSnack(context, 'ໃນກະຕ່າມີຄົບ ${CartProvider.maxQty} ໃບແລ້ວ', error: true);
        return;
      }
      setState(() => _busy = true);
      final ok = await addToCart(context, p, qty: _qty.clamp(1, maxAdd));
      if (!mounted) return;
      setState(() {
        _busy = false;
        _qty = 1;
      });
      if (ok && goCart) {
        context.read<NavProvider>().setTab(NavProvider.cart);
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }

    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kPrimary,
        actions: [
          IconButton(
            tooltip: 'ກະຕ່າ',
            onPressed: () {
              context.read<NavProvider>().setTab(NavProvider.cart);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            icon: Badge(
              isLabelVisible: inCart > 0,
              label: Text('$inCart'),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _busy ? null : () => add(goCart: false),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('ໃສ່ກະຕ່າ'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kPrimary,
                    ),
                    onPressed: _busy ? null : () => add(goCart: true),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('ຊື້ດຽວນີ້'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Hero(
                    tag: 'product-${p.id}',
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: NetImage(p.image,
                          placeholderColor: kPrimaryDark),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  if (p.categoryName.isNotEmpty)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p.categoryName,
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text('${formatPrice(p.price)} ກີບ / ໃບ',
                  style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                p.detail,
                style: const TextStyle(
                    fontSize: 14, color: Colors.white70, height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _row(Icons.calendar_today, p.date),
                  _row(Icons.alarm, p.time),
                  _row(Icons.location_on, p.address),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ຈຳນວນບັດ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        inCart > 0 ? 'ໃນກະຕ່າແລ້ວ $inCart ໃບ' : 'ສູງສຸດ ${CartProvider.maxQty} ໃບ',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  QtyStepper(
                    qty: _qty,
                    onMinus: _qty > 1 ? () => setState(() => _qty--) : null,
                    onPlus: _qty < maxAdd ? () => setState(() => _qty++) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text, style: const TextStyle(color: Colors.white))),
          ],
        ),
      );
}
