import 'package:activity/core/theme.dart';
import 'package:activity/feature/cart/cart_page.dart';
import 'package:activity/feature/category/category_page.dart';
import 'package:activity/feature/history/history_page.dart';
import 'package:activity/feature/home/home_page.dart';
import 'package:activity/feature/profile/profile_page.dart';
import 'package:activity/providers/cart_provider.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/ticket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ໂຄງຫຼັກຂອງແອັບ + ແຖບນຳທາງລຸ່ມ
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _pages = [
    HomePage(),
    CategoryPage(),
    CartPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<NavProvider>().resetSilently();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    final cartCount = context.select<CartProvider, int>((c) => c.count);
    final activeTickets =
        context.select<TicketProvider, int>((t) => t.active.length);

    return Scaffold(
      body: IndexedStack(index: nav.index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kPrimary,
        currentIndex: nav.index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        onTap: nav.setTab,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ໜ້າຫຼັກ'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'ໝວດໝູ່'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(cartCount > 99 ? '99+' : '$cartCount'),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'ກະຕ່າ',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: activeTickets > 0,
              label: Text('$activeTickets'),
              backgroundColor: Colors.green,
              child: const Icon(Icons.receipt_long),
            ),
            label: 'ປະຫວັດ',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ໂປຣໄຟລ໌'),
        ],
      ),
    );
  }
}
