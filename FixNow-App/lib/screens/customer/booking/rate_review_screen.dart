import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../models/review.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/rating_stars.dart';

class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key, required this.booking});
  final Booking booking;

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _submitting = true);

    try {
      await DbService.reviews.push().set(
            Review(
              id: '',
              bookingId: widget.booking.id,
              customerId: user.uid,
              customerName: user.name,
              providerId: widget.booking.providerId,
              rating: _rating,
              comment: _commentController.text.trim(),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ).toMap(),
          );

      await DbService.bookings.child(widget.booking.id).update({'reviewed': true});

      final providerRef = DbService.providers.child(widget.booking.providerId);
      final snapshot = await providerRef.get();
      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        final currentRating = (data['rating'] as num?)?.toDouble() ?? 0;
        final currentCount = (data['ratingCount'] as num?)?.toInt() ?? 0;
        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + _rating) / newCount;
        await providerRef.update({'rating': newRating, 'ratingCount': newCount});
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your feedback!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Service')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Text(
                'How was your experience with\n${widget.booking.providerName}?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              RatingInput(rating: _rating, onChanged: (v) => setState(() => _rating = v)),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share details about the service (optional)',
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Submit Review', isLoading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
