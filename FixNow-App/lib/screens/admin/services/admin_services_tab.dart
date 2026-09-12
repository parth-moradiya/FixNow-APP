import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/service_category.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';

class AdminServicesTab extends StatelessWidget {
  const AdminServicesTab({super.key});

  Future<void> _addCategory(BuildContext context) async {
    final nameController = TextEditingController();
    String iconKey = ServiceCategory.iconKeys.first;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Service Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Category name'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ServiceCategory.iconKeys.map((key) {
                  final selected = key == iconKey;
                  return InkWell(
                    onTap: () => setDialogState(() => iconKey = key),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        ServiceCategory.iconForKey(key),
                        color: selected ? Colors.white : AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                try {
                  final id = DbService.categories.push().key!;
                  await DbService.categories.child(id).set(
                        ServiceCategory(id: id, name: name, iconKey: iconKey).toMap(),
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(friendlyErrorMessage(e))),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Service Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                IconButton.filled(
                  onPressed: () => _addCategory(context),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: DbService.categories.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const ErrorState();
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final raw = snapshot.data!.snapshot.value;
                var categories = <ServiceCategory>[];
                if (raw is Map) {
                  categories = raw.entries
                      .map((e) => ServiceCategory.fromMap(e.key as String, e.value as Map))
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
                }
                if (categories.isEmpty) {
                  return const EmptyState(icon: Icons.category_outlined, title: 'No categories yet');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                            child: Icon(c.icon, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          IconButton(
                            onPressed: () async {
                              try {
                                await DbService.categories.child(c.id).remove();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(friendlyErrorMessage(e))),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
