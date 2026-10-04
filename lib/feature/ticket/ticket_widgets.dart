import 'package:activity/core/models.dart';
import 'package:activity/core/theme.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';

/// ວາດລາຍ QR ແບບງ່າຍໆ ຈາກລະຫັດບັດ (ບໍ່ຕ້ອງໃຊ້ package ເພີ່ມ).
/// ຖ້າຕ້ອງການ QR ທີ່ສະແກນໄດ້ແທ້ ໃຫ້ໃຊ້ package `qr_flutter`.
class TicketQr extends StatelessWidget {
  final String data;
  final double size;
  final bool faded;
  const TicketQr({super.key, required this.data, this.size = 200, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.25 : 1,
      child: CustomPaint(
        size: Size.square(size),
        painter: _QrPainter(data),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  _QrPainter(this.data);

  static const int n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / n;
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    // pseudo-random ຈາກ hash ຂອງລະຫັດ
    // Park–Miller: ປອດໄພທັງ mobile ແລະ web
    int seed = data.codeUnits.fold(7, (a, b) => (a * 31 + b) % 2147483647);
    if (seed == 0) seed = 1;
    bool next() {
      seed = (seed * 16807) % 2147483647;
      return seed % 100 < 50;
    }

    bool inFinder(int x, int y) {
      bool box(int ox, int oy) => x >= ox && x < ox + 8 && y >= oy && y < oy + 8;
      return box(0, 0) || box(n - 8, 0) || box(0, n - 8);
    }

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (inFinder(x, y)) continue;
        if (next()) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }

    void finder(int ox, int oy) {
      final o = Offset(ox * cell, oy * cell);
      canvas.drawRect(o & Size(cell * 7, cell * 7), paint);
      canvas.drawRect((o + Offset(cell, cell)) & Size(cell * 5, cell * 5),
          Paint()..color = Colors.white);
      canvas.drawRect((o + Offset(cell * 2, cell * 2)) & Size(cell * 3, cell * 3), paint);
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.data != data;
}

class StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final used = status == TicketStatus.used;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: used ? Colors.grey.shade200 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        used ? 'ໃຊ້ແລ້ວ' : 'ພ້ອມໃຊ້',
        style: TextStyle(
          color: used ? Colors.grey.shade700 : Colors.green.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ບັດແບບລາຍການ ໃຊ້ໃນໜ້າ "ບັດຂອງຂ້ອຍ"
class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = ticket;
    final used = ticket.isUsed;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: ColorFiltered(
                  colorFilter: used
                      ? const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ])
                      : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                  child: NetImage(e.image, width: 95),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          StatusBadge(status: ticket.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _line(Icons.calendar_today, '${e.date}  •  ${e.time}'),
                      _line(Icons.location_on, e.address),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.confirmation_number,
                              size: 14, color: used ? Colors.grey : kPrimary),
                          const SizedBox(width: 4),
                          Text(ticket.code,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: used ? Colors.grey : kPrimary,
                              )),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                      if (used && ticket.usedAt != null)
                        Text('ໃຊ້ເມື່ອ: ${formatDateTime(ticket.usedAt!)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(icon, size: 13, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ),
          ],
        ),
      );
}
