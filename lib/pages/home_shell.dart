import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import 'dashboard.dart';
import 'cravings_list.dart';
import 'progress.dart';
import 'support.dart';

class HomeShell extends StatefulWidget {
  final UserProfile profile;
  final StorageService storage;
  const HomeShell({super.key, required this.profile, required this.storage});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(profile: widget.profile, storage: widget.storage),
      CravingsListScreen(storage: widget.storage),
      ProgressScreen(profile: widget.profile, storage: widget.storage),
      const SupportScreen(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), label: 'Cravings'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), label: 'Support'),
        ],
      ),
    );
  }
}


