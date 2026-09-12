import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/role_card.dart';
import 'login_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  UserRole? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Welcome to FixNow', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Tell us how you\'d like to use the app',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              RoleCard(
                role: UserRole.customer,
                selected: _selected == UserRole.customer,
                onTap: () => setState(() => _selected = UserRole.customer),
              ),
              const SizedBox(height: 14),
              RoleCard(
                role: UserRole.provider,
                selected: _selected == UserRole.provider,
                onTap: () => setState(() => _selected = UserRole.provider),
              ),
              const SizedBox(height: 14),
              RoleCard(
                role: UserRole.admin,
                selected: _selected == UserRole.admin,
                onTap: () => setState(() => _selected = UserRole.admin),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Continue',
                onPressed: _selected == null
                    ? null
                    : () {
                        context.read<AuthProvider>().selectRole(_selected!);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
