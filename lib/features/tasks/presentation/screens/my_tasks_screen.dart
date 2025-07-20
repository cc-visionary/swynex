import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(title: 'My Tasks'),
      body: const Center(
        child: Text(
          'Worker\'s Daily Task List',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
