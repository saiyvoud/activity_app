import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/feature/ticket/ticket_detail_page.dart';
import 'package:activity/feature/ticket/ticket_widgets.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/ticket_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ໃບບິນ (ໃບຮັບເງິນ) ຂອງຄຳສັ່ງຊື້
class BillPage extends StatelessWidget {
  final PurchaseOrder order;

  /// true = ຫາກໍ່ຊຳລະເງິນສຳເລັດ (ສະແດງຫົວຂໍ້ສຳເລັດ ແລະ ປຸ່ມໄປຕໍ່)
  final bool justPaid;

  const BillPage({super.key, required this.order, this.justPaid = false});

  void _goto(BuildContext context, VoidCallback action) {
    action();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final tickets = context.watch<TicketProvider>().byOrder(order.id);
    final nav = context.read<NavProvider>();

    return Scaffold(
        appBar: AppBar(
          title: Text(justPaid ? 'ຊຳລະເງິນສຳເລັດ' : 'ໃບບິນ'),
          automaticallyImplyLeading: !justPaid,
          actions: [
            if (justPaid)
              IconButton(
                onPressed: () => _goto(context, () => nav.setTab(NavProvider.home)),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (justPaid) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 70),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text('ຊື້ບັດສຳເລັດ!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
            _Receipt(order: order),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('ບັດໃນບິນນີ້ (${tickets.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            if (tickets.isEmpty)
              WhiteCard(
                child: Text(
                  order.ticketCodes.isEmpty
                      ? 'ບໍ່ມີບັດ'
                      : order.ticketCodes.join(', '),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              )
            else
              ...tickets.map((t) => TicketCard(
                    ticket: t,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TicketDetailPage(code: t.code)),
                    ),
                  )),
            const SizedBox(height: 16),
          ],
        ),
        bottomNavigationBar: justPaid
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _goto(context, () => nav.goHistory(1)),
                        icon: const Icon(Icons.confirmation_number),
                        label: const Text('ເບິ່ງບັດຂອງຂ້ອຍ'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50)),
                        onPressed: () =>
                            _goto(context, () => nav.setTab(NavProvider.home)),
                        child: const Text('ກັບໜ້າຫຼັກ'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
    );
  }
}

class _Receipt extends StatelessWidget {
  final PurchaseOrder order;
  const _Receipt({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                const Text('Activity',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 2),
                SelectableText(order.billNo,
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'monospace')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                KeyValueRow('ວັນທີ', formatDateTime(order.createdAt)),
                KeyValueRow('ລູກຄ້າ', order.customerName),
                KeyValueRow('ອີເມວ', order.customerEmail),
                KeyValueRow('ເບີໂທ', order.customerPhone.isEmpty ? '-' : order.customerPhone),
                KeyValueRow('ຊຳລະຜ່ານ', order.paymentMethod),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('ສະຖານະ', style: TextStyle(color: Colors.grey.shade600)),
                      const Spacer(),
                      OrderStatusChip(status: order.status),
                    ],
                  ),
                ),
                const _DashedLine(),
                for (final it in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${formatPrice(it.price)} ກີບ × ${it.qty}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('${formatPrice(it.subtotal)} ກີບ'),
                      ],
                    ),
                  ),
                const _DashedLine(),
                KeyValueRow('ລາຄາລວມ', '${formatPrice(order.subtotal)} ກີບ'),
                KeyValueRow('ຄ່າທຳນຽມ', '${formatPrice(order.fee)} ກີບ'),
                const Divider(),
                KeyValueRow('ລວມທັງໝົດ', '${formatPrice(order.total)} ກີບ',
                    bold: true),
                const SizedBox(height: 8),
                Text('ຂອບໃຈທີ່ໃຊ້ບໍລິການ 🙏',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: LayoutBuilder(
          builder: (context, c) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (c.maxWidth / 10).floor(),
              (_) => Container(width: 5, height: 1.5, color: Colors.grey.shade300),
            ),
          ),
        ),
      );
}

class OrderStatusChip extends StatelessWidget {
  final String status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final paid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: paid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        paid ? 'ຊຳລະແລ້ວ' : status,
        style: TextStyle(
          color: paid ? Colors.green.shade700 : Colors.orange.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
