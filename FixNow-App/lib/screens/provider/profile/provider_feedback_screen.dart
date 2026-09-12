import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/review.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/rating_stars.dart';

class ProviderFeedbackScreen extends StatelessWidget {
  const ProviderFeedbackScreen({super.key, required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Feedback')),
      body: StreamBuilder<DatabaseEvent>(
        stream: DbService.reviews.orderByChild('providerId').equalTo(providerId).onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorState();
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final raw = snapshot.data!.snapshot.value;
          var reviews = <Review>[];
          if (raw is Map) {
            reviews = raw.entries.map((e) => Review.fromMap(e.key as String, e.value as Map)).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }
          if (reviews.isEmpty) {
            return const EmptyState(icon: Icons.reviews_outlined, title: 'No feedback yet');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = reviews[i];
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
                        Text(r.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        RatingStars(rating: r.rating, size: 15),
                      ],
                    ),
                    if (r.comment.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(r.comment, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
