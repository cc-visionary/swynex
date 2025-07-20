import 'package:flutter/material.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Dashboard')),
      body: const Center(child: Text('Upcoming health tasks and protocols.')),
    );
  }
}
