import 'package:activity/core/theme.dart';
import 'package:flutter/material.dart';

/// ຮູບຈາກ URL ພ້ອມ placeholder ຕອນໂຫຼດ ແລະ ຕອນຜິດພາດ
class NetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color placeholderColor;

  const NetImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback(IconData icon) => Container(
          width: width,
          height: height,
          color: placeholderColor,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.black26),
        );
    if (url.isEmpty) return fallback(Icons.image);
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback(Icons.image_outlined),
      errorBuilder: (context, error, stack) => fallback(Icons.broken_image),
    );
  }
}

/// ໜ້າວ່າງ / ບໍ່ມີຂໍ້ມູນ
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionText;
  final VoidCallback? onAction;
  final bool actionLoading;

  const EmptyView({
    super.key,
    required this.icon,
    required this.text,
    this.actionText,
    this.onAction,
    this.actionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            if (actionText != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: actionLoading ? null : onAction,
                  child: actionLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text(actionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ສະແດງ error ຈາກ Firebase ພ້ອມປຸ່ມລອງໃໝ່
class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final denied = error.contains('permission') || error.contains('denied');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 70, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              denied
                  ? 'ບໍ່ມີສິດອ່ານຂໍ້ມູນ - ກວດ Rules ຂອງ Realtime Database'
                  : 'ໂຫຼດຂໍ້ມູນບໍ່ສຳເລັດ',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(error,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ລອງໃໝ່'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ກ່ອງສີຂາວມົນ
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );
}

/// ແຖວ ປ້າຍ : ຄ່າ
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const KeyValueRow(this.label, this.value, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: bold ? kPrimary : null,
                ),
              ),
            ),
          ],
        ),
      );
}

/// ປຸ່ມ + / -
class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  const QtyStepper({super.key, required this.qty, this.onMinus, this.onPlus});

  Widget _btn(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: onTap == null ? Colors.grey.shade200 : kPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 16, color: onTap == null ? Colors.grey : Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onMinus),
          SizedBox(
            width: 34,
            child: Text('$qty',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          _btn(Icons.add, onPlus),
        ],
      );
}

/// ປຸ່ມທີ່ສະແດງວົງໝູນຕອນກຳລັງໂຫຼດ
class LoadingButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final Widget child;
  const LoadingButton(
      {super.key, required this.loading, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : child,
      );
}
