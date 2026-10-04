# Activity — ແອັບຊື້ບັດກິດຈະກຳ (Flutter + Firebase + Provider)

## ຕັ້ງຄ່າກ່ອນລັນ (ເຮັດຄັ້ງດຽວ)

1. **Firebase Console → Authentication → Sign-in method** → ເປີດ **Email/Password**
2. **Realtime Database → Rules** → ກັອບປີ້ເນື້ອຫາໃນ `database.rules.json` ໄປວາງ ແລ້ວກົດ **Publish**
3. ລັນ:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
4. ລົງທະບຽນບັນຊີໃໝ່ໃນແອັບ → ໜ້າຫຼັກຈະວ່າງ → ກົດ **"ເພີ່ມຂໍ້ມູນຕົວຢ່າງ"** ເພື່ອສ້າງ categories + products ໃນ Firebase

> ຮອງຮັບ **Android** (ໃຊ້ `google-services.json`). ຖ້າຕ້ອງການ iOS/Web ໃຫ້ລັນ `flutterfire configure`.

## ໂຄງສ້າງຂໍ້ມູນ (Realtime Database)

```
categories/{categoryId}        name, icon, description, order
products/{productId}           title, categoryId, category, date, time, image, address, price, detail, createdAt
users/{uid}                    uid, name, email, phone, photoUrl, createdAt
carts/{uid}/{productId}        productId, title, image, price, qty, date, time, address, addedAt
orders/{uid}/{orderId}         billNo, items[], subtotal, fee, total, paymentMethod, status, customer*, ticketCodes[], createdAt
tickets/{uid}/{code}           code, orderId, billNo, productId, title, ..., status(active|used), purchasedAt, usedAt
notifications/{uid}/{id}       title, body, type(purchase|used|reminder|system), read, createdAt
```

ເພີ່ມສິນຄ້າ/ໝວດໝູ່ເອງໄດ້ໃນ Firebase Console — ແອັບຈະອັບເດດ realtime ທັນທີ.

## State management (Provider)

| Provider | ໜ້າທີ່ | Path |
|---|---|---|
| `AppAuthProvider` | Login / Register / Logout / ລືມລະຫັດ / ແກ້ໂປຣໄຟລ໌ / ປ່ຽນລະຫັດ | Firebase Auth + `users/{uid}` |
| `CategoryProvider` | ໝວດໝູ່ | `categories` |
| `ProductProvider` | ສິນຄ້າ + ຄົ້ນຫາ + ກັ່ນຕອງ + ເພີ່ມຂໍ້ມູນຕົວຢ່າງ | `products` |
| `CartProvider` | ກະຕ່າ: ເພີ່ມ / ປ່ຽນຈຳນວນ / ລຶບ / ລ້າງ | `carts/{uid}` |
| `OrderProvider` | ຊຳລະເງິນ → ສ້າງບິນ + ບັດ + ແຈ້ງເຕືອນ + ລ້າງກະຕ່າ (multi-path update) | `orders/{uid}` |
| `TicketProvider` | ບັດຂອງຂ້ອຍ / ນຳໃຊ້ບັດ | `tickets/{uid}` |
| `NotificationProvider` | ແຈ້ງເຕືອນ: ອ່ານ / ອ່ານທັງໝົດ / ລຶບ | `notifications/{uid}` |
| `NavProvider` | ແທັບລຸ່ມ ແລະ ແທັບຍ່ອຍໃນໜ້າປະຫວັດ | – |

ທຸກ Provider ທີ່ຂຶ້ນກັບຜູ້ໃຊ້ສືບທອດຈາກ `UserBoundProvider` ແລະ ຖືກຜູກກັບ Auth ຜ່ານ
`ChangeNotifierProxyProvider` ໃນ `main.dart` — login/logout ຈະເລີ່ມ/ຢຸດຟັງຂໍ້ມູນເອງອັດຕະໂນມັດ.

## ໂຄງສ້າງໂຟນເດີ

```
lib/
  main.dart                  Firebase.initializeApp + MultiProvider + AuthGate
  firebase_options.dart
  core/        db.dart, models.dart, theme.dart, seed_data.dart
  providers/   auth, catalog (category+product), cart, order, ticket, notification, nav
  widgets/     common.dart (NetImage, EmptyView, ErrorView, QtyStepper, ...)
  feature/
    auth/          login_page, register_page
    shell/         main_shell (bottom nav: ໜ້າຫຼັກ, ໝວດໝູ່, ກະຕ່າ, ປະຫວັດ, ໂປຣໄຟລ໌)
    home/          home_page
    product/       product_widgets, product_detail_page
    category/      category_page (+ ProductListPage)
    cart/          cart_page, checkout_page
    bill/          bill_page
    history/       history_page (ການຊື້ / ບັດພ້ອມໃຊ້ / ໃຊ້ແລ້ວ)
    ticket/        ticket_widgets, ticket_detail_page
    notification/  notification_page
    profile/       profile_page, edit_profile_page (+ ChangePasswordPage)
```

## Run ໃນ Chrome (Web)

```bash
flutter pub get
flutter run -d chrome
```

Build ເປັນເວັບ: `flutter build web` (ໄຟລ໌ອອກຢູ່ `build/web`).

ໝາຍເຫດ: ຄ່າ Firebase ສຳລັບ Web ຢູ່ໃນ `lib/firebase_options.dart` (`DefaultFirebaseOptions.web`).
ຖ້າມີບັນຫາ, ໃຫ້ລົງທະບຽນ Web app ໃນ Firebase Console ແລ້ວເອົາ `appId` ແບບ `...:web:...` ມາແທນ.
