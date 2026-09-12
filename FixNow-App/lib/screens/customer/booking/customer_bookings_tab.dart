import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/status_badge.dart';
import 'booking_detail_screen.dart';

class CustomerBookingsTab extends StatelessWidget {
  const CustomerBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('My Bookings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: uid == null
                ? const SizedBox.shrink()
                : StreamBuilder<DatabaseEvent>(
                    stream: DbService.bookings.orderByChild('customerId').equalTo(uid).onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const ErrorState();
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final raw = snapshot.data!.snapshot.value;
                      var bookings = <Booking>[];
                      if (raw is Map) {
                        bookings = raw.entries
                            .map((e) => Booking.fromMap(e.key as String, e.value as Map))
                            .toList()
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      }
                      if (bookings.isEmpty) {
                        return const EmptyState(
                          icon: Icons.calendar_month_outlined,
                          title: 'No bookings yet',
                          subtitle: 'Browse services and book your first appointment',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: bookings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = bookings[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: b)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(b.categoryName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      StatusBadge(status: b.status),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text('with ${b.providerName}', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 6),
                                      Text('${b.date} • ${b.time}', style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
