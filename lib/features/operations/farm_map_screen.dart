import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';

class FarmMapScreen extends StatelessWidget {
  const FarmMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(title: 'Farm Map'),
      body: const Center(
        child: Text(
          'Visual Layout of the Farm',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
