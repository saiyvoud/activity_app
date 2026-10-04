import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const String kDatabaseUrl =
    'https://activity-lao-default-rtdb.asia-southeast1.firebasedatabase.app';

/// ທາງເຂົ້າ Firebase Realtime Database ຂອງແອັບ
///
/// ໂຄງສ້າງຂໍ້ມູນ:
///   categories/{categoryId}
///   products/{productId}
///   users/{uid}
///   carts/{uid}/{productId}
///   orders/{uid}/{orderId}          (ບິນ / ປະຫວັດການຊື້)
///   tickets/{uid}/{ticketCode}
///   notifications/{uid}/{notificationId}
class Db {
  Db._();

  static final FirebaseDatabase instance = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: kDatabaseUrl,
  );

  static DatabaseReference ref([String? path]) => instance.ref(path);

  /// ສ້າງ key ໃໝ່ (ແບບ push) ໂດຍບໍ່ຂຽນຂໍ້ມູນ
  static String newKey(String path) => ref(path).push().key!;

  static Map<String, Object?> notificationData({
    required String title,
    required String body,
    String type = 'system',
  }) =>
      {
        'title': title,
        'body': body,
        'type': type,
        'read': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

  /// ເພີ່ມແຈ້ງເຕືອນໃຫ້ຜູ້ໃຊ້
  static Future<void> pushNotification(
    String uid, {
    required String title,
    required String body,
    String type = 'system',
  }) {
    return ref('notifications/$uid')
        .push()
        .set(notificationData(title: title, body: body, type: type));
  }
}
