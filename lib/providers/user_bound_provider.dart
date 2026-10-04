import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Provider ພື້ນຖານ: ຟັງຂໍ້ມູນ realtime ຈາກ Firebase ຕາມຜູ້ໃຊ້ທີ່ login.
/// ເມື່ອ uid ປ່ຽນ (login / logout) ຈະຍົກເລີກການຟັງເກົ່າ ແລະ ເລີ່ມຟັງໃໝ່.
abstract class UserBoundProvider extends ChangeNotifier {
  String? _uid;
  String? get uid => _uid;

  StreamSubscription<DatabaseEvent>? _sub;
  bool _loading = false;
  bool get loading => _loading;
  String? _error;
  String? get error => _error;
  bool _disposed = false;

  /// Query ທີ່ຈະຟັງ
  Query buildQuery(String uid);

  /// ແປງ snapshot ເປັນ list ຂອງ provider
  void onSnapshot(DataSnapshot snapshot);

  /// ລ້າງຂໍ້ມູນເມື່ອ logout
  void clear();

  /// ຖືກເອີ້ນຈາກ ChangeNotifierProxyProvider ທຸກຄັ້ງທີ່ Auth ປ່ຽນ.
  /// ຫ້າມ notifyListeners ໃນນີ້ ເພາະຖືກເອີ້ນລະຫວ່າງ build.
  void bindUser(String? uid) {
    if (uid == _uid) return;
    _sub?.cancel();
    _sub = null;
    _uid = uid;
    _error = null;
    clear();
    if (uid == null) {
      _loading = false;
      return;
    }
    _loading = true;
    _sub = buildQuery(uid).onValue.listen(
      (event) {
        _loading = false;
        _error = null;
        onSnapshot(event.snapshot);
        notify();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notify();
      },
    );
  }

  /// ເຊື່ອມຕໍ່ໃໝ່ (ໃຊ້ກັບປຸ່ມ "ລອງໃໝ່" / pull to refresh)
  Future<void> refresh() async {
    final u = _uid;
    _uid = null;
    bindUser(u);
    notify();
  }

  void notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
