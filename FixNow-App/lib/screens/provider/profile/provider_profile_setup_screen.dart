import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/service_category.dart';
import '../../../models/service_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';
import '../provider_home_shell.dart';

class ProviderProfileSetupScreen extends StatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  State<ProviderProfileSetupScreen> createState() => _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState extends State<ProviderProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();
  ServiceCategory? _selectedCategory;
  bool _saving = false;

  @override
  void dispose() {
    _priceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose a service category')),
        );
      }
      return;
    }
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final profile = ServiceProviderProfile(
        uid: user.uid,
        name: user.name,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        bio: _bioController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        available: true,
      );
      await DbService.providers.child(user.uid).set(profile.toMap());

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProviderHomeShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell customers about your service',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'This appears on your public profile so customers can book you',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Service category',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
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
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ServiceCategory>(
                          value: _selectedCategory,
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Choose a category'),
                          ),
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
                  hint: 'e.g. 1500',
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
                const Text(
                  'Bio / experience',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 5 years experience fixing residential electrical issues',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Tell customers about yourself' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Save & Continue', isLoading: _saving, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
