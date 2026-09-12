import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/service_category.dart';
import '../../../models/service_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/rating_stars.dart';
import 'provider_profile_screen.dart';

enum _SortBy { rating, priceLowHigh }

class CategoryProvidersScreen extends StatefulWidget {
  const CategoryProvidersScreen({super.key, required this.category});
  final ServiceCategory category;

  @override
  State<CategoryProvidersScreen> createState() => _CategoryProvidersScreenState();
}

class _CategoryProvidersScreenState extends State<CategoryProvidersScreen> {
  _SortBy _sort = _SortBy.rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text('Sort by:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Rating'),
                  selected: _sort == _SortBy.rating,
                  onSelected: (_) => setState(() => _sort = _SortBy.rating),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Price: Low to High'),
                  selected: _sort == _SortBy.priceLowHigh,
                  onSelected: (_) => setState(() => _sort = _SortBy.priceLowHigh),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: DbService.providers.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const ErrorState();
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final raw = snapshot.data!.snapshot.value;
                var providers = <ServiceProviderProfile>[];
                if (raw is Map) {
                  providers = raw.entries
                      .map((e) => ServiceProviderProfile.fromMap(e.key as String, e.value as Map))
                      .where((p) => p.categoryId == widget.category.id)
                      .toList();
                }
                providers.sort((a, b) => _sort == _SortBy.rating
                    ? b.rating.compareTo(a.rating)
                    : a.price.compareTo(b.price));

                if (providers.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No providers in this category yet',
                    subtitle: 'Try another category or check back later',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: providers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = providers[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProviderProfileScreen(provider: p)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      RatingStars(rating: p.rating, size: 14),
                                      const SizedBox(width: 6),
                                      Text('(${p.ratingCount})', style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.available ? 'Available now' : 'Currently unavailable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: p.available ? AppColors.success : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rs ${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
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
