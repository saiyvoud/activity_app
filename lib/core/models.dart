// Models ທັງໝົດຂອງແອັບ ພ້ອມແປງ ຈາກ/ໄປ Firebase Realtime Database

// ---------------- helpers ----------------

Map<String, dynamic> asMap(Object? v) {
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return <String, dynamic>{};
}

List<Object?> asList(Object? v) {
  if (v is List) return v.where((e) => e != null).toList();
  if (v is Map) return v.values.toList();
  return const [];
}

int toInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.replaceAll(',', '').trim()) ?? 0;
  return 0;
}

String toStr(Object? v, [String fallback = '']) =>
    (v == null || v.toString().isEmpty) ? fallback : v.toString();

DateTime toDate(Object? v) {
  final ms = toInt(v);
  return ms == 0 ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(ms);
}

// ---------------- User ----------------

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.photoUrl = '',
    required this.createdAt,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        name: toStr(m['name'] ?? m['username'], 'ຜູ້ໃຊ້'),
        email: toStr(m['email']),
        phone: toStr(m['phone']),
        photoUrl: toStr(m['photoUrl'] ?? m['profile']),
        createdAt: toDate(m['createdAt']),
      );

  Map<String, Object?> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}

// ---------------- Category ----------------

class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int order;

  const CategoryItem({
    required this.id,
    required this.name,
    this.icon = '',
    this.description = '',
    this.order = 0,
  });

  factory CategoryItem.fromMap(String id, Map<String, dynamic> m) =>
      CategoryItem(
        id: id,
        name: toStr(m['name'] ?? m['category_name'], id),
        icon: toStr(m['icon']),
        description: toStr(m['description']),
        order: toInt(m['order']),
      );

  Map<String, Object?> toMap() => {
        'name': name,
        'icon': icon,
        'description': description,
        'order': order,
      };
}

// ---------------- Product (ກິດຈະກຳ) ----------------

class Product {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final String date;
  final String time;
  final String image;
  final String address;
  final int price;
  final String detail;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    required this.time,
    required this.image,
    required this.address,
    required this.price,
    required this.detail,
    required this.createdAt,
  });

  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
        id: id,
        title: toStr(m['title'] ?? m['name'], 'ບໍ່ມີຊື່'),
        categoryId: toStr(m['categoryId'] ?? m['category_id']),
        categoryName: toStr(m['category'] ?? m['categoryName']),
        date: toStr(m['date'], '-'),
        time: toStr(m['time'], '-'),
        image: toStr(m['image'] ?? m['imageUrl']),
        address: toStr(m['address'], '-'),
        price: toInt(m['price']),
        detail: toStr(m['detail'] ?? m['description']),
        createdAt: toDate(m['createdAt']),
      );

  Map<String, Object?> toMap() => {
        'title': title,
        'categoryId': categoryId,
        'category': categoryName,
        'date': date,
        'time': time,
        'image': image,
        'address': address,
        'price': price,
        'detail': detail,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}

// ---------------- Cart ----------------

class CartItem {
  final String productId;
  final String title;
  final String image;
  final int price;
  final int qty;
  final String date;
  final String time;
  final String address;
  final DateTime addedAt;

  const CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.qty,
    required this.date,
    required this.time,
    required this.address,
    required this.addedAt,
  });

  int get subtotal => price * qty;

  factory CartItem.fromProduct(Product p, int qty) => CartItem(
        productId: p.id,
        title: p.title,
        image: p.image,
        price: p.price,
        qty: qty,
        date: p.date,
        time: p.time,
        address: p.address,
        addedAt: DateTime.now(),
      );

  factory CartItem.fromMap(String id, Map<String, dynamic> m) => CartItem(
        productId: toStr(m['productId'], id),
        title: toStr(m['title']),
        image: toStr(m['image']),
        price: toInt(m['price']),
        qty: toInt(m['qty']) <= 0 ? 1 : toInt(m['qty']),
        date: toStr(m['date'], '-'),
        time: toStr(m['time'], '-'),
        address: toStr(m['address'], '-'),
        addedAt: toDate(m['addedAt']),
      );

  Map<String, Object?> toMap() => {
        'productId': productId,
        'title': title,
        'image': image,
        'price': price,
        'qty': qty,
        'date': date,
        'time': time,
        'address': address,
        'addedAt': addedAt.millisecondsSinceEpoch,
      };
}

// ---------------- Order / Bill ----------------

class PurchaseOrder {
  final String id;
  final String billNo;
  final List<CartItem> items;
  final int subtotal;
  final int fee;
  final int total;
  final String paymentMethod;
  final String status; // paid
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<String> ticketCodes;
  final DateTime createdAt;

  const PurchaseOrder({
    required this.id,
    required this.billNo,
    required this.items,
    required this.subtotal,
    required this.fee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.ticketCodes,
    required this.createdAt,
  });

  int get itemCount => items.fold(0, (s, i) => s + i.qty);

  factory PurchaseOrder.fromMap(String id, Map<String, dynamic> m) =>
      PurchaseOrder(
        id: id,
        billNo: toStr(m['billNo'], id),
        items: asList(m['items'])
            .map((e) => CartItem.fromMap('', asMap(e)))
            .toList(),
        subtotal: toInt(m['subtotal']),
        fee: toInt(m['fee']),
        total: toInt(m['total']),
        paymentMethod: toStr(m['paymentMethod'], '-'),
        status: toStr(m['status'], 'paid'),
        customerName: toStr(m['customerName'], '-'),
        customerEmail: toStr(m['customerEmail'], '-'),
        customerPhone: toStr(m['customerPhone'], '-'),
        ticketCodes: asList(m['ticketCodes']).map((e) => e.toString()).toList(),
        createdAt: toDate(m['createdAt']),
      );

  Map<String, Object?> toMap() => {
        'billNo': billNo,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'fee': fee,
        'total': total,
        'paymentMethod': paymentMethod,
        'status': status,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'ticketCodes': ticketCodes,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}

// ---------------- Ticket ----------------

enum TicketStatus { active, used }

class Ticket {
  final String code;
  final String orderId;
  final String billNo;
  final String productId;
  final String title;
  final String image;
  final String date;
  final String time;
  final String address;
  final int price;
  final String paymentMethod;
  final TicketStatus status;
  final DateTime purchasedAt;
  final DateTime? usedAt;

  const Ticket({
    required this.code,
    required this.orderId,
    required this.billNo,
    required this.productId,
    required this.title,
    required this.image,
    required this.date,
    required this.time,
    required this.address,
    required this.price,
    required this.paymentMethod,
    required this.status,
    required this.purchasedAt,
    this.usedAt,
  });

  bool get isUsed => status == TicketStatus.used;

  factory Ticket.fromMap(String code, Map<String, dynamic> m) => Ticket(
        code: toStr(m['code'], code),
        orderId: toStr(m['orderId']),
        billNo: toStr(m['billNo']),
        productId: toStr(m['productId']),
        title: toStr(m['title']),
        image: toStr(m['image']),
        date: toStr(m['date'], '-'),
        time: toStr(m['time'], '-'),
        address: toStr(m['address'], '-'),
        price: toInt(m['price']),
        paymentMethod: toStr(m['paymentMethod'], '-'),
        status: m['status'] == 'used' ? TicketStatus.used : TicketStatus.active,
        purchasedAt: toDate(m['purchasedAt']),
        usedAt: m['usedAt'] == null ? null : toDate(m['usedAt']),
      );

  Map<String, Object?> toMap() => {
        'code': code,
        'orderId': orderId,
        'billNo': billNo,
        'productId': productId,
        'title': title,
        'image': image,
        'date': date,
        'time': time,
        'address': address,
        'price': price,
        'paymentMethod': paymentMethod,
        'status': isUsed ? 'used' : 'active',
        'purchasedAt': purchasedAt.millisecondsSinceEpoch,
        'usedAt': usedAt?.millisecondsSinceEpoch,
      };
}

// ---------------- Notification ----------------

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // purchase | used | system | reminder
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) =>
      AppNotification(
        id: id,
        title: toStr(m['title']),
        body: toStr(m['body']),
        type: toStr(m['type'], 'system'),
        read: m['read'] == true,
        createdAt: toDate(m['createdAt']),
      );
}
