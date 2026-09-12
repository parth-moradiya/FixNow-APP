import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/app_user.dart';
import '../../../models/user_role.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  UserRole _filter = UserRole.customer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Manage Users', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Customers'),
                  selected: _filter == UserRole.customer,
                  onSelected: (_) => setState(() => _filter = UserRole.customer),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Providers'),
                  selected: _filter == UserRole.provider,
                  onSelected: (_) => setState(() => _filter = UserRole.provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: DbService.users.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const ErrorState();
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final raw = snapshot.data!.snapshot.value;
                var users = <AppUser>[];
                if (raw is Map) {
                  users = raw.entries
                      .map((e) => AppUser.fromMap(e.key as String, e.value as Map))
                      .where((u) => u.role == _filter)
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
                }
                if (users.isEmpty) {
                  return const EmptyState(icon: Icons.people_outline, title: 'No users found');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(u.email, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Switch(
                                value: u.active,
                                activeThumbColor: AppColors.primary,
                                onChanged: (v) => DbService.users.child(u.uid).update({'active': v}),
                              ),
                              Text(
                                u.active ? 'Active' : 'Suspended',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: u.active ? AppColors.success : AppColors.error,
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
