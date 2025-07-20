import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:pig_lifecycle_crm/features/settings/data/models/user_model.dart';
import 'package:provider/provider.dart';
import '../view_models/user_management_view_model.dart';

// This one function now handles both adding and editing
void showAddEditUserDialog(BuildContext context, {AppUser? user}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder:
        (_) => ChangeNotifierProvider.value(
          value: Provider.of<UserManagementViewModel>(context, listen: false),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _AddEditUserDialogContent(user: user),
          ),
        ),
  );
}

class _AddEditUserDialogContent extends StatefulWidget {
  final AppUser? user;
  const _AddEditUserDialogContent({this.user});

  @override
  State<_AddEditUserDialogContent> createState() =>
      _AddEditUserDialogContentState();
}

class _AddEditUserDialogContentState extends State<_AddEditUserDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.worker;

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email;
      _selectedRole = UserRole.values.firstWhere(
        (r) => r.name == widget.user!.role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UserManagementViewModel>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and optional Delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditMode ? 'Edit User' : 'Add New User',
                  style: theme.textTheme.headlineSmall,
                ),
                if (isEditMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Are you sure?'),
                              content: Text(
                                'Delete user ${widget.user!.fullName}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                      );
                      // TODO: delete to automatically remove auth as well
                      if (confirm == true) {
                        await viewModel.deleteUser(widget.user!.id);
                        if (mounted) Navigator.of(context).pop();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator:
                  (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              // Email should not be changed in edit mode
              readOnly: isEditMode,
              validator:
                  (value) => value!.isEmpty ? 'Please enter an email' : null,
            ),
            const SizedBox(height: 16),
            // Only show password field when adding a new user
            if (!isEditMode)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (value) =>
                        (value?.length ?? 0) < 6
                            ? 'Must be at least 6 characters'
                            : null,
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              items:
                  UserRole.values
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedRole = value!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String? error;
                      if (isEditMode) {
                        final updatedUser = AppUser(
                          id: widget.user!.id,
                          fullName: _nameController.text,
                          email:
                              _emailController
                                  .text, // Not changed, but needed for the object
                          role: _selectedRole.name,
                        );
                        error = await viewModel.updateUser(updatedUser);
                      } else {
                        error = await viewModel.addUser(
                          email: _emailController.text,
                          password: _passwordController.text,
                          fullName: _nameController.text,
                          role: _selectedRole.name,
                        );
                      }
                      if (mounted) {
                        if (error == null) {
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        }
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
