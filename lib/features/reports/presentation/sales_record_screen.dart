import 'package:flutter/material.dart';

class SalesRecordsScreen extends StatelessWidget {
  const SalesRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Records')),
      body: const Center(
        child: Text('A list of sales records will be shown here.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement showAddSaleDialog(context)
        },
        tooltip: 'Add Sale',
        child: const Icon(Icons.add),
      ),
    );
  }
}
