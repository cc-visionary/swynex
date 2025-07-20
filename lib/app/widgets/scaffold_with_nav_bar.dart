import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/features/auth/providers/auth_provider.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).userRole;

    final navBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.pets_outlined),
        label: 'Pigs',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.health_and_safety_outlined),
        label: 'Health',
      ),
    ];

    // Define navigation items for different roles
    final managerItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.task_alt),
        label: 'Task Board',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pigs'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        label: 'Farm Map',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Reports',
      ),
    ];

    final workerItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.checklist),
        label: 'My Tasks',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.qr_code_scanner),
        label: 'Scan',
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: userRole == UserRole.worker ? workerItems : managerItems,
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
