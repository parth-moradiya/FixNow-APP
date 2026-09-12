import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_notification.dart';
import '../../../models/booking.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/status_badge.dart';

class ProviderBookingsTab extends StatelessWidget {
  const ProviderBookingsTab({super.key});

  Future<void> _advance(BuildContext context, Booking b) async {
    final next = b.status == BookingStatus.accepted ? BookingStatus.inProgress : BookingStatus.completed;
    try {
      await DbService.bookings.child(b.id).update({'status': next.storageValue});

      if (next == BookingStatus.completed) {
        final providerRef = DbService.providers.child(b.providerId);
        final snapshot = await providerRef.get();
        if (snapshot.exists) {
          final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
          final jobs = (data['completedJobs'] as num?)?.toInt() ?? 0;
          await providerRef.update({'completedJobs': jobs + 1});
        }
      }

      await DbService.notifications(b.customerId).push().set(
            AppNotification(
              id: '',
              title: 'Booking update',
              body: next == BookingStatus.inProgress
                  ? '${b.providerName} started your ${b.categoryName} job'
                  : '${b.providerName} marked your ${b.categoryName} job as completed',
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ).toMap(),
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('My Jobs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
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
                      var jobs = <Booking>[];
                      if (raw is Map) {
                        jobs = raw.entries
                            .map((e) => Booking.fromMap(e.key as String, e.value as Map))
                            .where((b) => b.status != BookingStatus.pending)
                            .toList()
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      }
                      if (jobs.isEmpty) {
                        return const EmptyState(
                          icon: Icons.work_outline,
                          title: 'No jobs yet',
                          subtitle: 'Accepted bookings will appear here',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: jobs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = jobs[i];
                          final canAdvance =
                              b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress;
                          return Container(
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
                                    Text(b.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    StatusBadge(status: b.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(b.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 6),
                                Text('${b.date} • ${b.time}', style: Theme.of(context).textTheme.bodyMedium),
                                if (canAdvance) ...[
                                  const SizedBox(height: 12),
                                  PrimaryButton(
                                    label: b.status == BookingStatus.accepted ? 'Start Job' : 'Mark Completed',
                                    onPressed: () => _advance(context, b),
                                  ),
                                ],
                              ],
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
