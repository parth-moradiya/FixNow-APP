import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/app_notification.dart';
import '../../../models/booking.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  Future<void> _sendAnnouncement(BuildContext context) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final send = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Title')),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send to all users')),
        ],
      ),
    );

    if (send != true) return;
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    try {
      final usersSnapshot = await DbService.users.get();
      if (usersSnapshot.exists && usersSnapshot.value is Map) {
        final users = Map<dynamic, dynamic>.from(usersSnapshot.value as Map);
        for (final uid in users.keys) {
          await DbService.notifications(uid as String).push().set(
                AppNotification(
                  id: '',
                  title: title,
                  body: body,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                ).toMap(),
              );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement sent to all users')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const Text('Reports', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Booking breakdown by status', style: TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
          const SizedBox(height: 20),
          StreamBuilder<DatabaseEvent>(
            stream: DbService.bookings.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ErrorState();
              }
              final raw = snapshot.data?.snapshot.value;
              var bookings = <Booking>[];
              if (raw is Map) {
                bookings = raw.entries.map((e) => Booking.fromMap(e.key as String, e.value as Map)).toList();
              }
              return Column(
                children: BookingStatus.values.map((status) {
                  final count = bookings.where((b) => b.status == status).length;
                  final total = bookings.isEmpty ? 1 : bookings.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(status.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            Text('$count', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: count / total,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Announcements', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Send a notification to every registered user (customers and providers).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Send Announcement', onPressed: () => _sendAnnouncement(context)),
        ],
      ),
    );
  }
}
