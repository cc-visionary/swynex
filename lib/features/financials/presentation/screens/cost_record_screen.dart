import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/features/financials/data/models/cost_record_model.dart';
import '../view_models/cost_record_view_model.dart';
import '../widgets/add_cost_dialog.dart';

class CostRecordsScreen extends StatelessWidget {
  const CostRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CostRecordsViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cost Records')),
        body: Consumer<CostRecordsViewModel>(
          builder: (context, viewModel, _) {
            return StreamBuilder<List<CostRecord>>(
              stream: viewModel.costRecordsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cost records found.'));
                }
                final costs = snapshot.data!;
                return ListView.builder(
                  itemCount: costs.length,
                  itemBuilder: (context, index) {
                    final cost = costs[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(cost.description ?? 'No Description'),
                      subtitle: Text(cost.costCategory),
                      trailing: Text(
                        '-\$${cost.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () => showAddCostDialog(context),
              tooltip: 'Add Cost',
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
