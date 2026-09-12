import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/app_notification.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';

class CustomerNotificationsTab extends StatelessWidget {
  const CustomerNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: uid == null
                ? const SizedBox.shrink()
                : StreamBuilder<DatabaseEvent>(
                    stream: DbService.notifications(uid).onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const ErrorState();
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final raw = snapshot.data!.snapshot.value;
                      var items = <AppNotification>[];
                      if (raw is Map) {
                        items = raw.entries
                            .map((e) => AppNotification.fromMap(e.key as String, e.value as Map))
                            .toList()
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      }
                      if (items.isEmpty) {
                        return const EmptyState(icon: Icons.notifications_none_rounded, title: 'No notifications yet');
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final n = items[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => DbService.notifications(uid).child(n.id).update({'read': true}),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: n.read ? AppColors.surface : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    n.read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 3),
                                        Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('d MMM, h:mm a')
                                              .format(DateTime.fromMillisecondsSinceEpoch(n.createdAt)),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
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
