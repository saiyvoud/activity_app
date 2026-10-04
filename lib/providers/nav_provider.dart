import 'package:flutter/foundation.dart';

/// ຄວບຄຸມແທັບລຸ່ມ ແລະ ແທັບຍ່ອຍໃນໜ້າປະຫວັດ
class NavProvider extends ChangeNotifier {
  static const int home = 0;
  static const int category = 1;
  static const int cart = 2;
  static const int history = 3;
  static const int profile = 4;

  int _index = home;
  int get index => _index;

  /// ແທັບຍ່ອຍທີ່ຂໍໃຫ້ໜ້າປະຫວັດເປີດ: 0 = ການຊື້, 1 = ບັດພ້ອມໃຊ້, 2 = ໃຊ້ແລ້ວ
  int? _pendingHistoryTab;

  /// ອ່ານແລ້ວລ້າງ (ໃຊ້ຄັ້ງດຽວ)
  int? consumeHistoryTab() {
    final t = _pendingHistoryTab;
    _pendingHistoryTab = null;
    return t;
  }

  void setTab(int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }

  void goHistory(int subTab) {
    _index = history;
    _pendingHistoryTab = subTab;
    notifyListeners();
  }

  /// ໃຊ້ຕອນເຂົ້າສູ່ລະບົບໃໝ່ (ບໍ່ notify ເພາະຖືກເອີ້ນໃນ initState)
  void resetSilently() {
    _index = home;
    _pendingHistoryTab = null;
  }
}
