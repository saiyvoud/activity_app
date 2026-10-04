import 'package:activity/core/theme.dart';
import 'package:activity/feature/home/home_page.dart';
import 'package:activity/feature/notification/notification_page.dart';
import 'package:activity/feature/profile/edit_profile_page.dart';
import 'package:activity/providers/auth_provider.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/notification_provider.dart';
import 'package:activity/providers/order_provider.dart';
import 'package:activity/providers/ticket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ໂປຣໄຟລ໌: users/{uid} + ສະຖິຕິຈາກ orders / tickets
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ອອກຈາກລະບົບ?'),
        content: const Text('ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ຍົກເລີກ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ອອກຈາກລະບົບ'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppAuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().profile;
    final orders = context.watch<OrderProvider>();
    final tickets = context.watch<TicketProvider>();
    final unread = context.select<NotificationProvider, int>((n) => n.unreadCount);
    final nav = context.read<NavProvider>();
    if (user == null) return const SizedBox();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 24, 20, 28),
              decoration: const BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  UserAvatar(
                    photoUrl: user.photoUrl,
                    initial: user.initial,
                    radius: 44,
                    light: true,
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _stat('ການຊື້', '${orders.orders.length}'),
                      _stat('ບັດພ້ອມໃຊ້', '${tickets.active.length}'),
                      _stat('ໃຊ້ແລ້ວ', '${tickets.used.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section([
              _tile(Icons.person_outline, 'ຊື່', trailing: user.name),
              _tile(Icons.email_outlined, 'ອີເມວ', trailing: user.email),
              _tile(Icons.phone_outlined, 'ເບີໂທ',
                  trailing: user.phone.isEmpty ? '-' : user.phone),
              _tile(Icons.payments_outlined, 'ຍອດໃຊ້ຈ່າຍທັງໝົດ',
                  trailing: '${formatPrice(orders.totalSpent)} ກີບ'),
            ]),
            _section([
              _tile(Icons.edit_outlined, 'ແກ້ໄຂໂປຣໄຟລ໌',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EditProfilePage()))),
              _tile(Icons.lock_outline, 'ປ່ຽນລະຫັດຜ່ານ',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordPage()))),
            ]),
            _section([
              _tile(Icons.shopping_cart_outlined, 'ກະຕ່າຂອງຂ້ອຍ',
                  onTap: () => nav.setTab(NavProvider.cart)),
              _tile(Icons.receipt_long_outlined, 'ບິນ / ປະຫວັດການຊື້',
                  onTap: () => nav.goHistory(0)),
              _tile(Icons.confirmation_number_outlined, 'ບັດຂອງຂ້ອຍ',
                  onTap: () => nav.goHistory(1)),
              _tile(Icons.notifications_outlined, 'ແຈ້ງເຕືອນ',
                  badge: unread,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotificationPage()))),
            ]),
            _section([
              _tile(Icons.help_outline, 'ຊ່ວຍເຫຼືອ',
                  onTap: () => showSnack(context, 'ຕິດຕໍ່: support@activity.la')),
              _tile(Icons.info_outline, 'ກ່ຽວກັບແອັບ', trailing: 'v1.0.0'),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('ອອກຈາກລະບົບ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );

  Widget _section(List<Widget> children) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      );

  Widget _tile(IconData icon, String title,
      {String? trailing, VoidCallback? onTap, int badge = 0}) {
    return ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(title),
      onTap: onTap,
      trailing: trailing != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(trailing,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600)),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge > 0) Badge(label: Text('$badge')),
                const Icon(Icons.chevron_right),
              ],
            ),
    );
  }
}
