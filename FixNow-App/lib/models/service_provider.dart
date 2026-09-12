class ServiceProviderProfile {
  ServiceProviderProfile({
    required this.uid,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.bio,
    required this.price,
    required this.available,
    this.rating = 0,
    this.ratingCount = 0,
    this.completedJobs = 0,
  });

  final String uid;
  final String name;
  final String categoryId;
  final String categoryName;
  final String bio;
  final double price;
  final bool available;
  final double rating;
  final int ratingCount;
  final int completedJobs;

  factory ServiceProviderProfile.fromMap(String uid, Map<dynamic, dynamic> map) {
    return ServiceProviderProfile(
      uid: uid,
      name: map['name'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      available: map['available'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['ratingCount'] as num?)?.toInt() ?? 0,
      completedJobs: (map['completedJobs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'bio': bio,
        'price': price,
        'available': available,
        'rating': rating,
        'ratingCount': ratingCount,
        'completedJobs': completedJobs,
      };
}
