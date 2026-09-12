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

class ProviderRequestsTab extends StatelessWidget {
  const ProviderRequestsTab({super.key});

  Future<void> _respond(BuildContext context, Booking b, BookingStatus status) async {
    try {
      await DbService.bookings.child(b.id).update({'status': status.storageValue});
      await DbService.notifications(b.customerId).push().set(
            AppNotification(
              id: '',
              title: status == BookingStatus.accepted ? 'Booking accepted' : 'Booking declined',
              body: status == BookingStatus.accepted
                  ? '${b.providerName} accepted your booking for ${b.date}'
                  : '${b.providerName} declined your booking request',
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
            child: Text('Booking Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
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
                      var requests = <Booking>[];
                      if (raw is Map) {
                        requests = raw.entries
                            .map((e) => Booking.fromMap(e.key as String, e.value as Map))
                            .where((b) => b.status == BookingStatus.pending)
                            .toList()
                          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                      }
                      if (requests.isEmpty) {
                        return const EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'No pending requests',
                          subtitle: 'New booking requests will show up here',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: requests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = requests[i];
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
                                Text(b.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(b.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text('${b.date} • ${b.time}', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        b.address,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _respond(context, b, BookingStatus.cancelled),
                                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: PrimaryButton(
                                        label: 'Accept',
                                        onPressed: () => _respond(context, b, BookingStatus.accepted),
                                      ),
                                    ),
                                  ],
                                ),
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
