import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../theme/app_colors.dart';
import '../widgets/error_state.dart';
import 'admin/admin_home_shell.dart';
import 'auth/role_select_screen.dart';
import 'customer/customer_home_shell.dart';
import 'provider/provider_home_shell.dart';
import 'provider/profile/provider_profile_setup_screen.dart';

/// Sends a signed-in user to the right module home based on their role.
/// For providers, checks whether they've completed their service profile
/// yet and routes to setup first if not.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) return const RoleSelectScreen();

    switch (user.role) {
      case UserRole.customer:
        return const CustomerHomeShell();
      case UserRole.admin:
        return const AdminHomeShell();
      case UserRole.provider:
        return FutureBuilder(
          future: DbService.providers.child(user.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Scaffold(backgroundColor: AppColors.background, body: ErrorState());
            }
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final exists = snapshot.data!.exists;
            return exists ? const ProviderHomeShell() : const ProviderProfileSetupScreen();
          },
        );
    }
  }
}
