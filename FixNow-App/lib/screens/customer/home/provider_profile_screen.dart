import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/review.dart';
import '../../../models/service_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/rating_stars.dart';
import '../booking/book_service_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key, required this.provider});
  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                provider.name.isNotEmpty ? provider.name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(provider.name, style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 4),
          Center(child: Text(provider.categoryName, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingStars(rating: provider.rating, size: 18),
                const SizedBox(width: 6),
                Text('${provider.rating.toStringAsFixed(1)} (${provider.ratingCount} reviews)'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Price', value: 'Rs ${provider.price.toStringAsFixed(0)}')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Jobs done', value: '${provider.completedJobs}')),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Status',
                  value: provider.available ? 'Available' : 'Busy',
                  valueColor: provider.available ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('About', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            provider.bio.isEmpty ? 'This provider has not added a bio yet.' : provider.bio,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text('Reviews', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          _ReviewsList(providerId: provider.uid),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: provider.available ? 'Book Now' : 'Currently Unavailable',
            onPressed: provider.available
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookServiceScreen(provider: provider)),
                    )
                : null,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: valueColor ?? AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: DbService.reviews.orderByChild('providerId').equalTo(providerId).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorState();
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final raw = snapshot.data!.snapshot.value;
        var reviews = <Review>[];
        if (raw is Map) {
          reviews = raw.entries.map((e) => Review.fromMap(e.key as String, e.value as Map)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        if (reviews.isEmpty) {
          return const EmptyState(icon: Icons.rate_review_outlined, title: 'No reviews yet');
        }
        return Column(
          children: reviews.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                      Text(r.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      RatingStars(rating: r.rating, size: 14),
                    ],
                  ),
                  if (r.comment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(r.comment, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
