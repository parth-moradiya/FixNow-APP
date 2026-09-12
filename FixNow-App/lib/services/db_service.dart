import 'package:firebase_database/firebase_database.dart';
import '../models/service_category.dart';

/// Thin wrapper around the Realtime Database refs used across the app,
/// plus a one-time seed for default service categories so Browse Services
/// has content before an admin adds their own.
class DbService {
  DbService._();
  static final DatabaseReference _root = FirebaseDatabase.instance.ref();

  static DatabaseReference get users => _root.child('users');
  static DatabaseReference get categories => _root.child('categories');
  static DatabaseReference get providers => _root.child('providers');
  static DatabaseReference get bookings => _root.child('bookings');
  static DatabaseReference get reviews => _root.child('reviews');
  static DatabaseReference notifications(String uid) =>
      _root.child('notifications').child(uid);

  static const _defaultCategories = [
    {'id': 'plumbing', 'name': 'Plumbing', 'iconKey': 'plumbing'},
    {'id': 'electrical', 'name': 'Electrical', 'iconKey': 'electrical'},
    {'id': 'cleaning', 'name': 'Cleaning', 'iconKey': 'cleaning'},
    {'id': 'painting', 'name': 'Painting', 'iconKey': 'painting'},
    {'id': 'carpentry', 'name': 'Carpentry', 'iconKey': 'carpentry'},
    {'id': 'appliance', 'name': 'Appliance Repair', 'iconKey': 'appliance'},
  ];

  static Future<void> seedDefaultCategoriesIfEmpty() async {
    final snapshot = await categories.get();
    if (snapshot.exists) return;
    final updates = <String, dynamic>{};
    for (final c in _defaultCategories) {
      updates[c['id']!] = ServiceCategory(
        id: c['id']!,
        name: c['name']!,
        iconKey: c['iconKey']!,
      ).toMap();
    }
    await categories.update(updates);
  }
}
