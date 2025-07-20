import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: const HomeAppBar(title: 'Menu'),
      body: ListView(
        children: [
          _buildSectionHeader('Financials'),
          ListTile(
            leading: const Icon(Icons.point_of_sale_outlined),
            title: const Text('Sales Records'),
            onTap: () => context.push('/sales'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Cost Records'),
            onTap: () => context.push('/costs'),
          ),

          _buildSectionHeader('Operations'),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Inventory'),
            onTap: () => context.push('/inventory'),
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Farm Map'),
            onTap: () => context.push('/farm-map'),
          ),

          _buildSectionHeader('Settings'),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text('User Management'),
            onTap: () => context.push('/user-management'),
          ),
          ListTile(
            leading: const Icon(Icons.maps_home_work_outlined),
            title: const Text('Manage Farm Locations'),
            onTap: () => context.push('/farm-management'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => auth.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
