import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/feature/product/product_detail_page.dart';
import 'package:activity/providers/cart_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ເພີ່ມເຂົ້າກະຕ່າ ພ້ອມ SnackBar
Future<bool> addToCart(BuildContext context, Product p, {int qty = 1}) async {
  try {
    final ok = await context.read<CartProvider>().add(p, qty: qty);
    if (!context.mounted) return ok;
    showSnack(
      context,
      ok
          ? 'ເພີ່ມ "${p.title}" ເຂົ້າກະຕ່າແລ້ວ'
          : 'ຊື້ໄດ້ສູງສຸດ ${CartProvider.maxQty} ໃບ ຕໍ່ກິດຈະກຳ',
      error: !ok,
    );
    return ok;
  } catch (e) {
    if (context.mounted) showSnack(context, 'ເພີ່ມບໍ່ສຳເລັດ: $e', error: true);
    return false;
  }
}

/// ແຖບເລືອກໝວດໝູ່ແນວນອນ ('' = ທັງໝົດ)
class CategoryChips extends StatelessWidget {
  final List<CategoryItem> categories;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final all = [
      const CategoryItem(id: '', name: 'ທັງໝົດ'),
      ...categories,
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: all.length,
        itemBuilder: (context, index) {
          final c = all[index];
          final isSelected = selectedId == c.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ChoiceChip(
              label: Text(c.name),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onChanged(c.id),
              selectedColor: kPrimary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: isSelected ? kPrimary : Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }
}

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  childAspectRatio: 0.58,
);

/// Grid ຂອງສິນຄ້າ ສຳລັບໃຊ້ໃນ CustomScrollView
class ProductSliverGrid extends StatelessWidget {
  final List<Product> products;
  const ProductSliverGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) => SliverGrid.builder(
        gridDelegate: _gridDelegate,
        itemCount: products.length,
        itemBuilder: (context, i) => ProductCard(product: products[i]),
      );
}

/// Grid ຂອງສິນຄ້າ ແບບ scroll ໄດ້ເອງ
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: _gridDelegate,
        itemCount: products.length,
        itemBuilder: (context, i) => ProductCard(product: products[i]),
      );
}

/// ບັດສິນຄ້າ (ກິດຈະກຳ)
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final e = product;
    final inCart = context.select<CartProvider, int>((c) => c.qtyOf(e.id));
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(productId: e.id)),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'product-${e.id}',
                child: NetImage(e.image,
                    width: double.infinity, placeholderColor: kPrimaryDark),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _info(Icons.calendar_today, e.date),
                  _info(Icons.alarm, e.time),
                  _info(Icons.location_on, e.address),
                  const SizedBox(height: 4),
                  Text(
                    '${formatPrice(e.price)} ກີບ',
                    style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                height: 34,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => addToCart(context, e),
                  icon: const Icon(Icons.add_shopping_cart, size: 16, color: kPrimary),
                  label: Text(
                    inCart > 0 ? 'ໃນກະຕ່າ ($inCart)' : 'ໃສ່ກະຕ່າ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 13),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      );
}
