enum BookingStatus { pending, accepted, inProgress, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.pending => 'Pending',
        BookingStatus.accepted => 'Accepted',
        BookingStatus.inProgress => 'In Progress',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
      };

  String get storageValue => name;

  static BookingStatus fromStorage(String? value) {
    return BookingStatus.values.firstWhere(
      (s) => s.storageValue == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

class Booking {
  Booking({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.categoryName,
    required this.date,
    required this.time,
    required this.address,
    required this.price,
    required this.status,
    required this.createdAt,
    this.reviewed = false,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String providerId;
  final String providerName;
  final String categoryName;
  final String date;
  final String time;
  final String address;
  final double price;
  final BookingStatus status;
  final int createdAt;
  final bool reviewed;

  factory Booking.fromMap(String id, Map<dynamic, dynamic> map) {
    return Booking(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      address: map['address'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      status: BookingStatusX.fromStorage(map['status'] as String?),
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      reviewed: map['reviewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        'providerId': providerId,
        'providerName': providerName,
        'categoryName': categoryName,
        'date': date,
        'time': time,
        'address': address,
        'price': price,
        'status': status.storageValue,
        'createdAt': createdAt,
        'reviewed': reviewed,
      };
}
