import 'dart:async';

import 'package:activity/core/db.dart';
import 'package:activity/core/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// ຈັດການ Firebase Auth (email/password) ແລະ ໂປຣໄຟລ໌ຢູ່ users/{uid}
/// (ຕັ້ງຊື່ AppAuthProvider ເພື່ອບໍ່ໃຫ້ຊ້ຳກັບ AuthProvider ຂອງ firebase_auth)
class AppAuthProvider extends ChangeNotifier {
  AppAuthProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DatabaseEvent>? _profileSub;

  User? _user;
  AppUser? _profile;
  bool _initializing = true;
  bool _registering = false;

  User? get firebaseUser => _user;
  String? get uid => _user?.uid;
  bool get isLoggedIn => _user != null;
  bool get initializing => _initializing;

  /// ໂປຣໄຟລ໌ຈາກ database (ຖ້າຍັງໂຫຼດບໍ່ທັນ ໃຊ້ຂໍ້ມູນຈາກ Auth ແທນ)
  AppUser? get profile {
    final u = _user;
    if (u == null) return null;
    return _profile ?? _fromAuth(u);
  }

  DatabaseReference _userRef(String uid) => Db.ref('users/$uid');

  AppUser _fromAuth(User u) => AppUser(
        uid: u.uid,
        name: u.displayName ?? (u.email ?? 'ຜູ້ໃຊ້').split('@').first,
        email: u.email ?? '',
        photoUrl: u.photoURL ?? '',
        createdAt: u.metadata.creationTime ?? DateTime.now(),
      );

  void _onAuthChanged(User? u) {
    _user = u;
    _initializing = false;
    _profileSub?.cancel();
    _profileSub = null;
    _profile = null;
    if (u != null) {
      _profileSub = _userRef(u.uid).onValue.listen((event) {
        final v = event.snapshot.value;
        if (v == null) {
          // ບັນຊີທີ່ສ້າງຈາກ Firebase Console ຍັງບໍ່ມີໂປຣໄຟລ໌ -> ສ້າງໃຫ້
          if (!_registering) _userRef(u.uid).set(_fromAuth(u).toMap());
          return;
        }
        _profile = AppUser.fromMap(u.uid, asMap(v));
        notifyListeners();
      }, onError: (Object _) {});
    }
    notifyListeners();
  }

  // ---------------- actions ----------------

  /// ຄືນຄ່າ null ຖ້າສຳເລັດ, ບໍ່ດັ່ງນັ້ນຄືນຂໍ້ຄວາມ error
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user;
      if (u != null) {
        await Db.pushNotification(
          u.uid,
          title: 'ເຂົ້າສູ່ລະບົບສຳເລັດ',
          body: 'ຍິນດີຕ້ອນຮັບກັບມາ ${u.displayName ?? u.email}!',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorText(e.code);
    } catch (e) {
      return 'ເກີດຂໍ້ຜິດພາດ: $e';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _registering = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user!;
      await u.updateDisplayName(name.trim());
      final user = AppUser(
        uid: u.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );
      await _userRef(u.uid).set(user.toMap());
      await Db.pushNotification(
        u.uid,
        title: 'ລົງທະບຽນສຳເລັດ 🎉',
        body:
            'ຍິນດີຕ້ອນຮັບ ${user.name} ເຂົ້າສູ່ Activity. ເລີ່ມຊື້ບັດກິດຈະກຳໄດ້ເລີຍ!',
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorText(e.code);
    } catch (e) {
      return 'ເກີດຂໍ້ຜິດພາດ: $e';
    } finally {
      _registering = false;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorText(e.code);
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
    String photoUrl = '',
  }) async {
    final u = _user;
    if (u == null) return 'ກະລຸນາເຂົ້າສູ່ລະບົບ';
    try {
      await _userRef(u.uid).update({
        'name': name.trim(),
        'phone': phone.trim(),
        'photoUrl': photoUrl.trim(),
        'email': u.email,
        'uid': u.uid,
      });
      await u.updateDisplayName(name.trim());
      if (photoUrl.trim().isNotEmpty) await u.updatePhotoURL(photoUrl.trim());
      await Db.pushNotification(
        u.uid,
        title: 'ອັບເດດໂປຣໄຟລ໌',
        body: 'ຂໍ້ມູນໂປຣໄຟລ໌ຂອງທ່ານຖືກອັບເດດແລ້ວ',
      );
      return null;
    } catch (e) {
      return 'ບັນທຶກບໍ່ສຳເລັດ: $e';
    }
  }

  Future<String?> changePassword(String oldPass, String newPass) async {
    final u = _user;
    if (u == null || u.email == null) return 'ກະລຸນາເຂົ້າສູ່ລະບົບ';
    try {
      final cred =
          EmailAuthProvider.credential(email: u.email!, password: oldPass);
      await u.reauthenticateWithCredential(cred);
      await u.updatePassword(newPass);
      await Db.pushNotification(
        u.uid,
        title: 'ປ່ຽນລະຫັດຜ່ານ',
        body: 'ລະຫັດຜ່ານຂອງທ່ານຖືກປ່ຽນແລ້ວ',
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorText(e.code);
    }
  }

  Future<void> logout() => _auth.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}

/// ແປ error code ຂອງ Firebase Auth ເປັນພາສາລາວ
String authErrorText(String code) {
  switch (code) {
    case 'invalid-email':
      return 'ຮູບແບບອີເມວບໍ່ຖືກຕ້ອງ';
    case 'user-disabled':
      return 'ບັນຊີນີ້ຖືກປິດການໃຊ້ງານ';
    case 'user-not-found':
      return 'ບໍ່ພົບບັນຊີນີ້';
    case 'wrong-password':
    case 'invalid-credential':
      return 'ອີເມວ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ';
    case 'email-already-in-use':
      return 'ອີເມວນີ້ຖືກໃຊ້ແລ້ວ';
    case 'weak-password':
      return 'ລະຫັດຜ່ານອ່ອນເກີນໄປ (ຢ່າງໜ້ອຍ 6 ຕົວ)';
    case 'too-many-requests':
      return 'ພະຍາຍາມຫຼາຍເກີນໄປ ກະລຸນາລໍຖ້າບຶດໜຶ່ງ';
    case 'network-request-failed':
      return 'ບໍ່ມີອິນເຕີເນັດ';
    case 'operation-not-allowed':
      return 'ຍັງບໍ່ໄດ້ເປີດ Email/Password ໃນ Firebase Console';
    case 'requires-recent-login':
      return 'ກະລຸນາເຂົ້າສູ່ລະບົບໃໝ່ອີກຄັ້ງ';
    default:
      return 'ເກີດຂໍ້ຜິດພາດ ($code)';
  }
}
