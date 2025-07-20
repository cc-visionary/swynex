import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(title: 'Reports'),
      body: const Center(
        child: Text(
          'Financial and Operational Reports',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
