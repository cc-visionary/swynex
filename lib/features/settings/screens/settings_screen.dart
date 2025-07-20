import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/features/auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get the AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            children: [
              // The role switcher has been removed from here.

              // Admin tools are still conditionally visible
              if (auth.isManagerOrHigher) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Admin Tools',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people_alt_outlined),
                  title: const Text('User Management'),
                  onTap: () {
                    context.push('/settings/users');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.maps_home_work_outlined),
                  title: const Text('Farm Management'),
                  onTap: () {
                    context.push('/settings/management');
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  auth.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
