import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/booking.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/status_badge.dart';

class AdminBookingsTab extends StatefulWidget {
  const AdminBookingsTab({super.key});

  @override
  State<AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<AdminBookingsTab> {
  BookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('All Bookings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final s in BookingStatus.values) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: s.label,
                    selected: _filter == s,
                    onTap: () => setState(() => _filter = s),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: DbService.bookings.onValue,
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
                      .where((b) => _filter == null || b.status == _filter)
                      .toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }
                if (bookings.isEmpty) {
                  return const EmptyState(icon: Icons.event_note_outlined, title: 'No bookings found');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final b = bookings[i];
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
                              Text(b.categoryName, style: const TextStyle(fontWeight: FontWeight.w700)),
                              PopupMenuButton<BookingStatus>(
                                initialValue: b.status,
                                onSelected: (status) =>
                                    DbService.bookings.child(b.id).update({'status': status.storageValue}),
                                itemBuilder: (context) => BookingStatus.values
                                    .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                                    .toList(),
                                child: StatusBadge(status: b.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${b.customerName} → ${b.providerName}', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text('${b.date} • ${b.time}', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Rs ${b.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }
}
