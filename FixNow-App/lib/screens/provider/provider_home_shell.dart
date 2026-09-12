import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'bookings/provider_bookings_tab.dart';
import 'earnings/provider_earnings_tab.dart';
import 'notifications/provider_notifications_tab.dart';
import 'profile/provider_profile_tab.dart';
import 'requests/provider_requests_tab.dart';

class ProviderHomeShell extends StatefulWidget {
  const ProviderHomeShell({super.key});

  @override
  State<ProviderHomeShell> createState() => _ProviderHomeShellState();
}

class _ProviderHomeShellState extends State<ProviderHomeShell> {
  int _index = 0;

  static const _tabs = [
    ProviderRequestsTab(),
    ProviderBookingsTab(),
    ProviderEarningsTab(),
    ProviderNotificationsTab(),
    ProviderProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Earnings'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
