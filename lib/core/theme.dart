import 'package:flutter/material.dart';

/// ສີຫຼັກຂອງແອັບ
const Color kPrimary = Color.fromARGB(255, 4, 28, 248);
const Color kPrimaryDark = Color.fromARGB(255, 2, 14, 150);
const Color kBackground = Color(0xFFF4F6FB);

/// ຈັດຮູບແບບຕົວເລກໃຫ້ມີຈຸດຂັ້ນ (Thousands separator)
String formatPrice(dynamic price) {
  if (price == null) return '0';
  return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
}

String two(int n) => n.toString().padLeft(2, '0');

/// ວັນທີ ແລະ ເວລາ ແບບ dd/MM/yyyy HH:mm
String formatDateTime(DateTime d) =>
    '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';

/// ເວລາທີ່ຜ່ານມາ ເຊັ່ນ "5 ນາທີກ່ອນ"
String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return 'ຫາກໍ່ນີ້';
  if (diff.inMinutes < 60) return '${diff.inMinutes} ນາທີກ່ອນ';
  if (diff.inHours < 24) return '${diff.inHours} ຊົ່ວໂມງກ່ອນ';
  if (diff.inDays < 7) return '${diff.inDays} ມື້ກ່ອນ';
  return formatDateTime(d);
}

/// ໄອຄອນຂອງໝວດໝູ່ ຕາມ field `icon` ໃນ database (ຫຼື ເດົາຈາກຊື່)
IconData categoryIcon(String icon, [String name = '']) {
  final key = '${icon.toLowerCase()} ${name.toLowerCase()}';
  if (key.contains('school') || key.contains('ສຳມະນາ')) return Icons.school;
  if (key.contains('travel') || key.contains('ທ່ອງທ່ຽວ')) return Icons.flight_takeoff;
  if (key.contains('celebration') || key.contains('ກິດຈະກຳ')) return Icons.celebration;
  if (key.contains('ticket') || key.contains('ປີ້')) return Icons.confirmation_number;
  if (key.contains('course') || key.contains('ຄອສ')) return Icons.laptop_mac;
  if (key.contains('sport') || key.contains('ກິລາ')) return Icons.sports_soccer;
  if (key.contains('music') || key.contains('ດົນຕີ')) return Icons.music_note;
  if (key.contains('food') || key.contains('ອາຫານ')) return Icons.restaurant;
  return Icons.category;
}

/// ໄອຄອນ ແລະ ສີ ຂອງແຈ້ງເຕືອນ ຕາມ type
(IconData, Color) notificationStyle(String type) {
  switch (type) {
    case 'purchase':
      return (Icons.shopping_bag, Colors.green);
    case 'used':
      return (Icons.qr_code_scanner, Colors.orange);
    case 'reminder':
      return (Icons.event, Colors.purple);
    default:
      return (Icons.info, kPrimary);
  }
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, primary: kPrimary),
    scaffoldBackgroundColor: kBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
    ));
}
