import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Your Role',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => authProvider.signInWithRole(UserRole.owner),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Sign In as Owner'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => authProvider.signInWithRole(UserRole.manager),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Sign In as Manager'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => authProvider.signInWithRole(UserRole.worker),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Sign In as Worker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
