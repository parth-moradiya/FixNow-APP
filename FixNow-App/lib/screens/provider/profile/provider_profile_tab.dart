import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/service_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/rating_stars.dart';
import '../../auth/role_select_screen.dart';
import 'edit_provider_profile_screen.dart';
import 'provider_feedback_screen.dart';

class ProviderProfileTab extends StatelessWidget {
  const ProviderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return SafeArea(
      child: StreamBuilder<DatabaseEvent>(
        stream: DbService.providers.child(uid).onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorState();
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = ServiceProviderProfile.fromMap(
            uid,
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(profile.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingStars(rating: profile.rating, size: 16),
                        const SizedBox(width: 6),
                        Text('${profile.rating.toStringAsFixed(1)} (${profile.ratingCount})'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available for bookings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: profile.available,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => DbService.providers.child(uid).update({'available': v}),
                ),
              ),
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Icons.edit_outlined,
                label: 'Edit Service Profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditProviderProfileScreen(profile: profile)),
                ),
              ),
              _ProfileTile(
                icon: Icons.reviews_outlined,
                label: 'Customer Feedback',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProviderFeedbackScreen(providerId: uid)),
                ),
              ),
              const SizedBox(height: 20),
              _ProfileTile(
                icon: Icons.logout,
                label: 'Log Out',
                color: AppColors.error,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: color ?? AppColors.textDark, size: 20),
                const SizedBox(width: 14),
                Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: color)),
                const Spacer(),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
