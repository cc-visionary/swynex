import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import '../view_models/user_management_view_model.dart';
import '../widgets/add_edit_user_dialog.dart'; // <-- Update the import

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserManagementViewModel(),
      child: Consumer<UserManagementViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('User Management')),
            body: StreamBuilder<List<AppUser>>(
              stream: viewModel.usersStream,
              builder: (context, snapshot) {
                // Handle the loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Handle the error state
                if (snapshot.hasError) {
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                }

                // Handle the case where there is no data
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(user.fullName),
                      subtitle: Text(user.email),
                      trailing: Text(user.role),
                      onTap: () => showAddEditUserDialog(context, user: user),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              // Call the same dialog but without a user to add a new one
              onPressed: () => showAddEditUserDialog(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
