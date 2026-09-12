class Review {
  Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String providerId;
  final double rating;
  final String comment;
  final int createdAt;

  factory Review.fromMap(String id, Map<dynamic, dynamic> map) {
    return Review(
      id: id,
      bookingId: map['bookingId'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'bookingId': bookingId,
        'customerId': customerId,
        'customerName': customerName,
        'providerId': providerId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };
}
