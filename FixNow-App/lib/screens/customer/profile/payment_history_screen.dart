import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: uid == null
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
                      .where((b) => b.status == BookingStatus.completed)
                      .toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }
                if (bookings.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No payments yet',
                    subtitle: 'Charges from completed bookings will appear here',
                  );
                }
                final total = bookings.fold<double>(0, (sum, b) => sum + b.price);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total spent', style: TextStyle(color: Colors.white, fontSize: 14)),
                          Text(
                            'Rs ${total.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...bookings.map((b) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text('${b.providerName} • ${b.date}', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            Text(
                              'Rs ${b.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }
}
