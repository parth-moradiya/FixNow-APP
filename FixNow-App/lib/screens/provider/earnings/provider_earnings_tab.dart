import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';

class ProviderEarningsTab extends StatelessWidget {
  const ProviderEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Earnings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: uid == null
                ? const SizedBox.shrink()
                : StreamBuilder<DatabaseEvent>(
                    stream: DbService.bookings.orderByChild('providerId').equalTo(uid).onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const ErrorState();
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final raw = snapshot.data!.snapshot.value;
                      var completed = <Booking>[];
                      if (raw is Map) {
                        completed = raw.entries
                            .map((e) => Booking.fromMap(e.key as String, e.value as Map))
                            .where((b) => b.status == BookingStatus.completed)
                            .toList()
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      }
                      final total = completed.fold<double>(0, (sum, b) => sum + b.price);

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatBox(
                                  label: 'Total earnings',
                                  value: 'Rs ${total.toStringAsFixed(0)}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatBox(label: 'Jobs completed', value: '${completed.length}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('Completed jobs', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 12),
                          if (completed.isEmpty)
                            const EmptyState(icon: Icons.bar_chart_outlined, title: 'No completed jobs yet')
                          else
                            ...completed.map((b) {
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
                                          Text('${b.customerName} • ${b.date}', style: Theme.of(context).textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs ${b.price.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
        ],
      ),
    );
  }
}
