import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final BookingStatus status;

  Color get _color => switch (status) {
        BookingStatus.pending => AppColors.rating,
        BookingStatus.accepted => AppColors.primary,
        BookingStatus.inProgress => const Color(0xFF3B82F6),
        BookingStatus.completed => AppColors.success,
        BookingStatus.cancelled => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
