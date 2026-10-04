import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/feature/product/product_widgets.dart';
import 'package:activity/providers/catalog_providers.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ໝວດໝູ່ທັງໝົດ ຈາກ categories/
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>();
    final products = context.watch<ProductProvider>();

    Widget body;
    if (categories.loading && categories.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (categories.error != null && categories.items.isEmpty) {
      body = ErrorView(error: categories.error!, onRetry: categories.refresh);
    } else if (categories.items.isEmpty) {
      body = EmptyView(
        icon: Icons.category_outlined,
        text: 'ຍັງບໍ່ມີໝວດໝູ່ໃນ Firebase',
        actionText: 'ເພີ່ມຂໍ້ມູນຕົວຢ່າງ',
        actionLoading: products.seeding,
        onAction: () async {
          final err = await products.seedSampleData();
          if (context.mounted) {
            showSnack(context, err ?? 'ເພີ່ມຂໍ້ມູນສຳເລັດ', error: err != null);
          }
        },
      );
    } else {
      body = RefreshIndicator(
        onRefresh: categories.refresh,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: categories.items.length,
          itemBuilder: (context, i) {
            final c = categories.items[i];
            final count = products.byCategory(c).length;
            return _CategoryTile(category: c, count: count);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ໝວດໝູ່'),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryItem category;
  final int count;
  const _CategoryTile({required this.category, required this.count});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductListPage(category: category)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon(category.icon, category.name),
                    color: kPrimary, size: 28),
              ),
              const Spacer(),
              Text(category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$count ກິດຈະກຳ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ສິນຄ້າທັງໝົດໃນໝວດໝູ່ທີ່ເລືອກ
class ProductListPage extends StatelessWidget {
  final CategoryItem category;
  const ProductListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<ProductProvider>().byCategory(category);
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: list.isEmpty
          ? const EmptyView(
              icon: Icons.event_busy, text: 'ຍັງບໍ່ມີກິດຈະກຳໃນໝວດນີ້')
          : ProductGrid(products: list),
    );
  }
}
