import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_user.dart';
import '../../../models/booking.dart';
import '../../../models/user_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../auth/role_select_screen.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Admin Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                tooltip: 'Log Out',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Platform overview', style: TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
          const SizedBox(height: 20),
          StreamBuilder<DatabaseEvent>(
            stream: DbService.users.onValue,
            builder: (context, userSnap) {
              final raw = userSnap.data?.snapshot.value;
              var customers = 0;
              var providers = 0;
              if (raw is Map) {
                for (final e in raw.entries) {
                  final u = AppUser.fromMap(e.key as String, e.value as Map);
                  if (u.role == UserRole.customer) customers++;
                  if (u.role == UserRole.provider) providers++;
                }
              }
              return Row(
                children: [
                  Expanded(child: _StatCard(icon: Icons.person_outline, label: 'Customers', value: '$customers')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.engineering_outlined, label: 'Providers', value: '$providers')),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<DatabaseEvent>(
            stream: DbService.bookings.onValue,
            builder: (context, snapshot) {
              final raw = snapshot.data?.snapshot.value;
              var bookings = <Booking>[];
              if (raw is Map) {
                bookings = raw.entries.map((e) => Booking.fromMap(e.key as String, e.value as Map)).toList();
              }
              final total = bookings.length;
              final completed = bookings.where((b) => b.status == BookingStatus.completed).length;
              final pending = bookings.where((b) => b.status == BookingStatus.pending).length;
              final revenue = bookings
                  .where((b) => b.status == BookingStatus.completed)
                  .fold<double>(0, (sum, b) => sum + b.price);

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(icon: Icons.event_note_outlined, label: 'Total Bookings', value: '$total')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.hourglass_empty, label: 'Pending', value: '$pending')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(icon: Icons.check_circle_outline, label: 'Completed', value: '$completed')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.payments_outlined,
                          label: 'Total Revenue',
                          value: 'Rs ${revenue.toStringAsFixed(0)}',
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, this.highlight = false});
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: highlight ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: highlight ? Colors.white : AppColors.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: highlight ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: highlight ? Colors.white.withValues(alpha: 0.9) : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
