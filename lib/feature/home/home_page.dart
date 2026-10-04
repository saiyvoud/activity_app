import 'package:activity/core/theme.dart';
import 'package:activity/feature/notification/notification_page.dart';
import 'package:activity/feature/product/product_widgets.dart';
import 'package:activity/providers/auth_provider.dart';
import 'package:activity/providers/catalog_providers.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/notification_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ໜ້າຫຼັກ: ດຶງ categories + products ຈາກ Firebase ແບບ realtime
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final categories = context.watch<CategoryProvider>();
    final list = products.filtered(categories.items);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await products.refresh();
            await categories.refresh();
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: products.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'ຄົ້ນຫາກິດຈະກຳ ....',
                      suffixIcon: Icon(Icons.search_outlined),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CategoryChips(
                  categories: categories.items,
                  selectedId: products.categoryId,
                  onChanged: products.setCategory,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Row(children: [
                    const Text('ກິດຈະກຳ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${list.length} ລາຍການ',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ]),
                ),
              ),
              if (products.loading && products.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (products.error != null && products.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                      error: products.error!, onRetry: products.refresh),
                )
              else if (products.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    icon: Icons.cloud_upload_outlined,
                    text: 'ຍັງບໍ່ມີກິດຈະກຳໃນ Firebase\nກົດປຸ່ມລຸ່ມນີ້ເພື່ອເພີ່ມຂໍ້ມູນຕົວຢ່າງ',
                    actionText: 'ເພີ່ມຂໍ້ມູນຕົວຢ່າງ',
                    actionLoading: products.seeding,
                    onAction: () async {
                      final err = await products.seedSampleData();
                      if (context.mounted) {
                        showSnack(context, err ?? 'ເພີ່ມຂໍ້ມູນສຳເລັດ',
                            error: err != null);
                      }
                    },
                  ),
                )
              else if (list.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(icon: Icons.event_busy, text: 'ບໍ່ພົບກິດຈະກຳ'),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  sliver: ProductSliverGrid(products: list),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().profile;
    final unread = context.select<NotificationProvider, int>((n) => n.unreadCount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<NavProvider>().setTab(NavProvider.profile),
            child: UserAvatar(
                photoUrl: user?.photoUrl ?? '', initial: user?.initial ?? '?'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ສະບາຍດີ 👋',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(
                  user?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'ກະຕ່າ',
            onPressed: () => context.read<NavProvider>().setTab(NavProvider.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            tooltip: 'ແຈ້ງເຕືອນ',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationPage())),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications_none),
            ),
          ),
        ],
      ),
    );
  }
}

/// ຮູບໂປຣໄຟລ໌ (ຮູບຈາກ URL ຫຼື ຕົວອັກສອນທຳອິດ)
class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final String initial;
  final double radius;
  final bool light;
  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.initial,
    this.radius = 22,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = light ? Colors.white : kPrimary;
    final fg = light ? kPrimary : Colors.white;
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
      onForegroundImageError: photoUrl.isNotEmpty ? (e, s) {} : null,
      child: Text(initial,
          style: TextStyle(
              color: fg, fontWeight: FontWeight.bold, fontSize: radius * 0.8)),
    );
  }
}
