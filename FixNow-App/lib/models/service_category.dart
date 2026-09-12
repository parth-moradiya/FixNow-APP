import 'package:flutter/material.dart';

class ServiceCategory {
  ServiceCategory({required this.id, required this.name, required this.iconKey});

  final String id;
  final String name;
  final String iconKey;

  IconData get icon => iconForKey(iconKey);

  static IconData iconForKey(String key) {
    switch (key) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'painting':
        return Icons.format_paint;
      case 'carpentry':
        return Icons.carpenter;
      case 'appliance':
        return Icons.kitchen;
      default:
        return Icons.home_repair_service;
    }
  }

  static const iconKeys = [
    'plumbing',
    'electrical',
    'cleaning',
    'painting',
    'carpentry',
    'appliance',
    'other',
  ];

  factory ServiceCategory.fromMap(String id, Map<dynamic, dynamic> map) {
    return ServiceCategory(
      id: id,
      name: map['name'] as String? ?? '',
      iconKey: map['iconKey'] as String? ?? 'other',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'iconKey': iconKey};

  @override
  bool operator ==(Object other) => other is ServiceCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
