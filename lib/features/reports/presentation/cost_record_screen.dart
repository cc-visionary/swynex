import 'package:flutter/material.dart';

class CostRecordsScreen extends StatelessWidget {
  const CostRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cost Records')),
      body: const Center(
        child: Text('A list of cost records will be shown here.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement showAddCostDialog(context)
        },
        tooltip: 'Add Cost',
        child: const Icon(Icons.add),
      ),
    );
  }
}
