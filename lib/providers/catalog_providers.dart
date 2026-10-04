import 'package:activity/core/db.dart';
import 'package:activity/core/models.dart';
import 'package:activity/core/seed_data.dart';
import 'package:activity/providers/user_bound_provider.dart';
import 'package:firebase_database/firebase_database.dart';

/// ໝວດໝູ່ ຈາກ categories/
class CategoryProvider extends UserBoundProvider {
  List<CategoryItem> _items = [];
  List<CategoryItem> get items => _items;

  CategoryItem? byId(String id) => _items.where((c) => c.id == id).firstOrNull;

  @override
  Query buildQuery(String uid) => Db.ref('categories');

  @override
  void onSnapshot(DataSnapshot snapshot) {
    _items = snapshot.children
        .where((c) => c.value is Map)
        .map((c) => CategoryItem.fromMap(c.key!, asMap(c.value)))
        .toList()
      ..sort((a, b) => a.order != b.order
          ? a.order.compareTo(b.order)
          : a.name.compareTo(b.name));
  }

  @override
  void clear() => _items = [];
}

/// ກິດຈະກຳ / ສິນຄ້າ ຈາກ products/ ພ້ອມ ຄົ້ນຫາ ແລະ ກັ່ນຕອງຕາມໝວດໝູ່
class ProductProvider extends UserBoundProvider {
  List<Product> _items = [];
  List<Product> get items => _items;

  String _query = '';
  String get query => _query;

  /// '' = ທັງໝົດ
  String _categoryId = '';
  String get categoryId => _categoryId;

  bool _seeding = false;
  bool get seeding => _seeding;

  @override
  Query buildQuery(String uid) => Db.ref('products');

  @override
  void onSnapshot(DataSnapshot snapshot) {
    _items = snapshot.children
        .where((c) => c.value is Map)
        .map((c) => Product.fromMap(c.key!, asMap(c.value)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void clear() {
    _items = [];
    _query = '';
    _categoryId = '';
  }

  void setQuery(String q) {
    _query = q;
    notify();
  }

  void setCategory(String id) {
    _categoryId = id;
    notify();
  }

  Product? byId(String id) => _items.where((p) => p.id == id).firstOrNull;

  bool _matchCategory(Product p, CategoryItem c) =>
      p.categoryId == c.id || (p.categoryId.isEmpty && p.categoryName == c.name);

  List<Product> byCategory(CategoryItem c) =>
      _items.where((p) => _matchCategory(p, c)).toList();

  /// ລາຍການທີ່ສະແດງໃນໜ້າຫຼັກ (ຕາມ query + ໝວດໝູ່ທີ່ເລືອກ)
  List<Product> filtered(List<CategoryItem> categories) {
    final q = _query.trim().toLowerCase();
    final cat = categories.where((c) => c.id == _categoryId).firstOrNull;
    return _items.where((p) {
      final okCat = cat == null || _matchCategory(p, cat);
      final okQ = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q);
      return okCat && okQ;
    }).toList();
  }

  /// ເພີ່ມຂໍ້ມູນຕົວຢ່າງ (categories + products) ເຂົ້າ Firebase
  Future<String?> seedSampleData() async {
    _seeding = true;
    notify();
    try {
      await SeedData.seed();
      return null;
    } catch (e) {
      return 'ເພີ່ມຂໍ້ມູນບໍ່ສຳເລັດ: $e';
    } finally {
      _seeding = false;
      notify();
    }
  }
}
