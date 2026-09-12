import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../services/db_service.dart';
import '../../theme/app_colors.dart';
import '../auth/role_select_screen.dart';
import '../role_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    final minSplash = Future.delayed(const Duration(milliseconds: 1200));
    final firebaseUser = FirebaseAuth.instance.currentUser;

    Widget destination = const RoleSelectScreen();

    if (firebaseUser != null) {
      final snapshot = await DbService.users.child(firebaseUser.uid).get();
      if (snapshot.exists && mounted) {
        final user = AppUser.fromMap(firebaseUser.uid, snapshot.value as Map<dynamic, dynamic>);
        context.read<AuthProvider>().currentUser = user;
        context.read<AuthProvider>().selectedRole = user.role;
        destination = const RoleGate();
      }
    }

    await minSplash;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'FixNow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Home services, booked in minutes',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}
