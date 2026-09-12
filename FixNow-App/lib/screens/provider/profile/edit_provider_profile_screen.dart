import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/service_category.dart';
import '../../../models/service_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';

class EditProviderProfileScreen extends StatefulWidget {
  const EditProviderProfileScreen({super.key, required this.profile});
  final ServiceProviderProfile profile;

  @override
  State<EditProviderProfileScreen> createState() => _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _priceController = TextEditingController(text: widget.profile.price.toStringAsFixed(0));
  late final _bioController = TextEditingController(text: widget.profile.bio);
  ServiceCategory? _selectedCategory;
  bool _saving = false;

  @override
  void dispose() {
    _priceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final updates = <String, dynamic>{
        'price': double.tryParse(_priceController.text.trim()) ?? widget.profile.price,
        'bio': _bioController.text.trim(),
      };
      if (_selectedCategory != null) {
        updates['categoryId'] = _selectedCategory!.id;
        updates['categoryName'] = _selectedCategory!.name;
      }
      await DbService.providers.child(widget.profile.uid).update(updates);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Service Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Service category', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 8),
                StreamBuilder<DatabaseEvent>(
                  stream: DbService.categories.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const ErrorState();
                    }
                    final raw = snapshot.data?.snapshot.value;
                    var categories = <ServiceCategory>[];
                    if (raw is Map) {
                      categories = raw.entries
                          .map((e) => ServiceCategory.fromMap(e.key as String, e.value as Map))
                          .toList()
                        ..sort((a, b) => a.name.compareTo(b.name));
                    }
                    ServiceCategory? current;
                    for (final c in categories) {
                      if (c.id == widget.profile.categoryId) {
                        current = c;
                        break;
                      }
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ServiceCategory>(
                          value: _selectedCategory ?? current,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Starting price (Rs)',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your starting price';
                    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Bio / experience', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Tell customers about yourself' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
