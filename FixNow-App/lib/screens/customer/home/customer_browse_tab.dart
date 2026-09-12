import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/service_category.dart';
import '../../../models/service_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/rating_stars.dart';
import 'category_providers_screen.dart';
import 'provider_profile_screen.dart';

class CustomerBrowseTab extends StatefulWidget {
  const CustomerBrowseTab({super.key});

  @override
  State<CustomerBrowseTab> createState() => _CustomerBrowseTabState();
}

class _CustomerBrowseTabState extends State<CustomerBrowseTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().currentUser?.name ?? '';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text('Hi, $name 👋', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('What do you need fixed today?', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Search a service category',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _CategoriesGrid(query: _query),
          const SizedBox(height: 28),
          Text('Top rated providers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const _TopProviders(),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: DbService.categories.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorState();
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final raw = snapshot.data!.snapshot.value;
        var categories = <ServiceCategory>[];
        if (raw is Map) {
          categories = raw.entries
              .map((e) => ServiceCategory.fromMap(e.key as String, e.value as Map))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        }
        if (query.isNotEmpty) {
          categories = categories.where((c) => c.name.toLowerCase().contains(query)).toList();
        }
        if (categories.isEmpty) {
          return const EmptyState(icon: Icons.category_outlined, title: 'No categories found');
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) {
            final c = categories[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CategoryProvidersScreen(category: c)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(c.icon, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        c.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TopProviders extends StatelessWidget {
  const _TopProviders();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: DbService.providers.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorState();
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final raw = snapshot.data!.snapshot.value;
        var providers = <ServiceProviderProfile>[];
        if (raw is Map) {
          providers = raw.entries
              .map((e) => ServiceProviderProfile.fromMap(e.key as String, e.value as Map))
              .where((p) => p.available)
              .toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
        }
        if (providers.isEmpty) {
          return const EmptyState(
            icon: Icons.engineering_outlined,
            title: 'No providers yet',
            subtitle: 'Check back soon — providers are joining FixNow',
          );
        }
        return Column(
          children: providers.take(5).map((p) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProviderProfileScreen(provider: p)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Row(
                  children: [
                    Text(p.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    RatingStars(rating: p.rating, size: 13),
                  ],
                ),
                trailing: Text(
                  'Rs ${p.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
