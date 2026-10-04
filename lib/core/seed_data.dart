import 'package:activity/core/db.dart';

/// ຂໍ້ມູນຕົວຢ່າງ - ກົດປຸ່ມ "ເພີ່ມຂໍ້ມູນຕົວຢ່າງ" ໃນໜ້າຫຼັກ ເມື່ອຖານຂໍ້ມູນຍັງວ່າງ.
/// ໃຊ້ update() ຈຶ່ງບໍ່ລຶບຂໍ້ມູນເກົ່າທີ່ມີຢູ່ແລ້ວ.
class SeedData {
  SeedData._();

  static const _categories = <String, Map<String, Object?>>{
    'cat_seminar': {'name': 'ສຳມະນາ', 'icon': 'school', 'order': 1},
    'cat_travel': {'name': 'ທ່ອງທ່ຽວ', 'icon': 'travel', 'order': 2},
    'cat_activity': {'name': 'ກິດຈະກຳ', 'icon': 'celebration', 'order': 3},
    'cat_booking': {'name': 'ຈອງປີ້', 'icon': 'ticket', 'order': 4},
    'cat_course': {'name': 'ຄອສອອນລາຍ', 'icon': 'course', 'order': 5},
    'cat_sport': {'name': 'ກິລາ', 'icon': 'sport', 'order': 6},
  };

  static const _concert =
      'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/music-concert-flyer-design-template-2d59fde071fcf31f0d8a138b3a6e516d_screen.jpg?ts=1737708040';

  static const _products = <String, Map<String, Object?>>{
    'p_001': {
      'title': 'Thriving beyond the storm',
      'categoryId': 'cat_seminar',
      'category': 'ສຳມະນາ',
      'date': '28/8/2026',
      'time': '8:00 - 12:00',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUC1WcJ5NovCtPqqyATD7EVJSwh8mBAR-SXJ-JhESEj4f7P2NIkPK9VkxQ&s=10',
      'address': 'Bangkok Thailand',
      'price': 500000,
      'detail':
          'ສຳມະນາພັດທະນາຕົນເອງ ແລະ ທຸລະກິດ ຮຽນຮູ້ວິທີຜ່ານຜ່າວິກິດ ແລະ ເຕີບໂຕຢ່າງຍືນຍົງ ຈາກວິທະຍາກອນມືອາຊີບ.',
    },
    'p_002': {
      'title': 'Explore Laos',
      'categoryId': 'cat_travel',
      'category': 'ທ່ອງທ່ຽວ',
      'date': '31/10/2026',
      'time': '15:00 - 23:30',
      'image':
          'https://ak-d.tripcdn.com/images/1mi33224x9aaoeyor9D26.jpg?proc=resize%2Fm_z%2Cw_375%2Ch_0%3Bformat%2Ff_webp%2C9C2E',
      'address': 'Laos PDR',
      'price': 500000,
      'detail':
          'ທ່ອງທ່ຽວສຳຫຼວດທຳມະຊາດ ແລະ ວັດທະນະທຳລາວ ພ້ອມອາຫານພື້ນເມືອງ ແລະ ຄູ່ມືນຳທ່ຽວຕະຫຼອດເສັ້ນທາງ.',
    },
    'p_003': {
      'title': 'Biggest Music',
      'categoryId': 'cat_activity',
      'category': 'ກິດຈະກຳ',
      'date': '28/8/2026',
      'time': '8:00 - 12:00',
      'image': _concert,
      'address': 'Bangkok Thailand',
      'price': 500000,
      'detail':
          'ຄອນເສີດດົນຕີທີ່ໃຫຍ່ທີ່ສຸດຂອງປີ ລວມສິລະປິນຊື່ດັງຫຼາຍກວ່າ 20 ວົງ ພ້ອມແສງສີສຽງເຕັມຮູບແບບ.',
    },
    'p_004': {
      'title': 'Run the canyon just outside',
      'categoryId': 'cat_booking',
      'category': 'ຈອງປີ້',
      'date': '28/8/2026',
      'time': '8:00 - 12:00',
      'image': 'https://picsum.photos/seed/canyonrun/600/800',
      'address': 'Bangkok Thailand',
      'price': 350000,
      'detail':
          'ງານວິ່ງເທຣວຜ່ານຫຸບເຂົາ ລະຍະທາງ 10 ແລະ 21 ກິໂລແມັດ ຮັບເສື້ອ ແລະ ຫຼຽນທີ່ລະນຶກທຸກຄົນ.',
    },
    'p_005': {
      'title': 'Flutter & Firebase Online',
      'categoryId': 'cat_course',
      'category': 'ຄອສອອນລາຍ',
      'date': '15/11/2026',
      'time': '19:00 - 21:00',
      'image': 'https://picsum.photos/seed/fluttercourse/600/800',
      'address': 'Online (Zoom)',
      'price': 250000,
      'detail':
          'ຄອສຮຽນສ້າງແອັບມືຖືດ້ວຍ Flutter ແລະ Firebase ຕັ້ງແຕ່ພື້ນຖານຈົນເຖິງການ deploy ພ້ອມໃບຢັ້ງຢືນ.',
    },
    'p_006': {
      'title': 'Vientiane Football Cup',
      'categoryId': 'cat_sport',
      'category': 'ກິລາ',
      'date': '5/12/2026',
      'time': '16:00 - 20:00',
      'image': 'https://picsum.photos/seed/footballcup/600/800',
      'address': 'ສະໜາມກິລາແຫ່ງຊາດ, ວຽງຈັນ',
      'price': 100000,
      'detail':
          'ການແຂ່ງຂັນບານເຕະນັດຊີງຊະນະເລີດ ຊິງຖ້ວຍນະຄອນຫຼວງ ບັດລວມບ່ອນນັ່ງ ແລະ ນ້ຳດື່ມ.',
    },
  };

  static Future<void> seed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updates = <String, Object?>{};
    _categories.forEach((id, data) => updates['categories/$id'] = data);
    var i = 0;
    _products.forEach((id, data) {
      updates['products/$id'] = {...data, 'createdAt': now - (i++ * 1000)};
    });
    return Db.ref().update(updates);
  }
}
