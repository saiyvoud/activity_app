// ຄ່າ Firebase ຂອງໂປຣເຈັກ activity-lao.
//  - Android: ເອົາມາຈາກ android/app/google-services.json
//  - Web (Chrome): ໃຊ້ apiKey / projectId / databaseURL ດຽວກັນ.
//    ແນະນຳ: ໄປ Firebase Console > Project settings > Your apps > Add app > Web (</>)
//    ແລ້ວເອົາ appId (ແບບ 1:775311317325:web:xxxx) ແລະ authDomain ມາແທນຄ່າໃນ `web` ລຸ່ມນີ້.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
            'ຍັງບໍ່ໄດ້ຕັ້ງຄ່າ Firebase ສຳລັບ $defaultTargetPlatform - ລັນ flutterfire configure');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAiX-miUFFI9m8ZAHjmZrheyrIKOsPTfbY',
    // TODO: ແທນດ້ວຍ Web appId ຂອງເຈົ້າ (1:775311317325:web:....) ຖ້າມີ
    appId: '1:775311317325:android:2ab2b7bddc01050e447f04',
    messagingSenderId: '775311317325',
    projectId: 'activity-lao',
    authDomain: 'activity-lao.firebaseapp.com',
    databaseURL:
        'https://activity-lao-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'activity-lao.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiX-miUFFI9m8ZAHjmZrheyrIKOsPTfbY',
    appId: '1:775311317325:android:2ab2b7bddc01050e447f04',
    messagingSenderId: '775311317325',
    projectId: 'activity-lao',
    databaseURL:
        'https://activity-lao-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'activity-lao.firebasestorage.app',
  );
}
