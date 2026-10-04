import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/notification_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ແຈ້ງເຕືອນ: notifications/{uid}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _unreadOnly = false;

  void _open(AppNotification n) {
    context.read<NotificationProvider>().markRead(n);
    final nav = context.read<NavProvider>();
    if (n.type == 'purchase') {
      nav.goHistory(0); // ປະຫວັດການຊື້
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else if (n.type == 'used' || n.type == 'reminder') {
      nav.goHistory(n.type == 'used' ? 2 : 1); // ບັດຂອງຂ້ອຍ
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ລຶບແຈ້ງເຕືອນທັງໝົດ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ຍົກເລີກ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ລຶບ')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<NotificationProvider>().clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationProvider>();
    return Builder(
      builder: (context) {
        final all = state.items;
        final list = _unreadOnly ? all.where((n) => !n.read).toList() : all;
        return Scaffold(
          appBar: AppBar(
            title: const Text('ແຈ້ງເຕືອນ'),
            actions: [
              IconButton(
                tooltip: 'ອ່ານທັງໝົດ',
                onPressed: state.unreadCount == 0 ? null : () => state.markAllRead(),
                icon: const Icon(Icons.done_all),
              ),
              IconButton(
                tooltip: 'ລຶບທັງໝົດ',
                onPressed: all.isEmpty ? null : _clearAll,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('ທັງໝົດ (${all.length})'),
                      selected: !_unreadOnly,
                      onSelected: (_) => setState(() => _unreadOnly = false),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('ຍັງບໍ່ອ່ານ (${state.unreadCount})'),
                      selected: _unreadOnly,
                      onSelected: (_) => setState(() => _unreadOnly = true),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.loading && all.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null && all.isEmpty
                    ? ErrorView(error: state.error!, onRetry: state.refresh)
                    : list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('ບໍ່ມີແຈ້ງເຕືອນ',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final n = list[i];
                          final (icon, color) = notificationStyle(n.type);
                          return Dismissible(
                            key: ValueKey(n.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => state.delete(n),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () => _open(n),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: n.read ? Colors.white : const Color(0xFFEAF0FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color.withValues(alpha: 0.15),
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(n.title,
                                                    style: TextStyle(
                                                        fontWeight: n.read
                                                            ? FontWeight.w500
                                                            : FontWeight.bold)),
                                              ),
                                              if (!n.read)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(n.body,
                                              style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 13,
                                                  height: 1.4)),
                                          const SizedBox(height: 6),
                                          Text(timeAgo(n.createdAt),
                                              style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
