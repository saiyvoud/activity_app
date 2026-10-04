import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/feature/bill/bill_page.dart';
import 'package:activity/feature/ticket/ticket_detail_page.dart';
import 'package:activity/feature/ticket/ticket_widgets.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/order_provider.dart';
import 'package:activity/providers/ticket_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ປະຫວັດ: ຄຳສັ່ງຊື້ (ບິນ) + ບັດພ້ອມໃຊ້ + ບັດໃຊ້ແລ້ວ
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  late final NavProvider _nav;

  @override
  void initState() {
    super.initState();
    _nav = context.read<NavProvider>();
    _nav.addListener(_syncTab);
  }

  /// ເມື່ອໜ້າອື່ນສັ່ງ goHistory(x) ໃຫ້ສະຫຼັບແທັບຍ່ອຍ
  void _syncTab() {
    if (_nav.index != NavProvider.history) return;
    final t = _nav.consumeHistoryTab();
    if (t != null && t != _tab.index) _tab.animateTo(t);
  }

  @override
  void dispose() {
    _nav.removeListener(_syncTab);
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final tickets = context.watch<TicketProvider>();
    final active = tickets.active;
    final used = tickets.used;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ປະຫວັດ'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'ການຊື້ (${orders.orders.length})'),
            Tab(text: 'ພ້ອມໃຊ້ (${active.length})'),
            Tab(text: 'ໃຊ້ແລ້ວ (${used.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _orders(orders),
          _tickets(tickets, active,
              emptyIcon: Icons.confirmation_number_outlined,
              emptyText: 'ທ່ານຍັງບໍ່ມີບັດ',
              showShop: true),
          _tickets(tickets, used,
              emptyIcon: Icons.history, emptyText: 'ຍັງບໍ່ມີບັດທີ່ນຳໃຊ້ແລ້ວ'),
        ],
      ),
    );
  }

  Widget _orders(OrderProvider p) {
    if (p.loading && p.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.error != null && p.orders.isEmpty) {
      return ErrorView(error: p.error!, onRetry: p.refresh);
    }
    if (p.orders.isEmpty) {
      return EmptyView(
        icon: Icons.receipt_long_outlined,
        text: 'ຍັງບໍ່ມີປະຫວັດການຊື້',
        actionText: 'ໄປເລືອກກິດຈະກຳ',
        onAction: () => _nav.setTab(NavProvider.home),
      );
    }
    return RefreshIndicator(
      onRefresh: p.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: p.orders.length,
        itemBuilder: (context, i) => OrderCard(order: p.orders[i]),
      ),
    );
  }

  Widget _tickets(
    TicketProvider p,
    List<Ticket> list, {
    required IconData emptyIcon,
    required String emptyText,
    bool showShop = false,
  }) {
    if (p.loading && p.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.error != null && p.tickets.isEmpty) {
      return ErrorView(error: p.error!, onRetry: p.refresh);
    }
    if (list.isEmpty) {
      return EmptyView(
        icon: emptyIcon,
        text: emptyText,
        actionText: showShop ? 'ໄປຊື້ບັດ' : null,
        onAction: () => _nav.setTab(NavProvider.home),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) => TicketCard(
        ticket: list[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailPage(code: list[i].code)),
        ),
      ),
    );
  }
}

/// ບັດສະຫຼຸບຄຳສັ່ງຊື້ໃນລາຍການປະຫວັດ
class OrderCard extends StatelessWidget {
  final PurchaseOrder order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final first = order.items.isNotEmpty ? order.items.first : null;
    final more = order.items.length - 1;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BillPage(order: order)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: kPrimary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(order.billNo,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetImage(first?.image ?? '', width: 54, height: 54),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first == null
                            ? '-'
                            : more > 0
                                ? '${first.title} ແລະ ອີກ $more ລາຍການ'
                                : first.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(formatDateTime(order.createdAt),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${order.itemCount} ໃບ • ${order.paymentMethod}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const Spacer(),
                Text('${formatPrice(order.total)} ກີບ',
                    style: const TextStyle(
                        color: kPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
