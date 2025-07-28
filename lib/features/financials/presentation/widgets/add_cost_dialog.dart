import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/features/financials/data/models/cost_record_model.dart';
import '../view_models/cost_record_view_model.dart';

void showAddCostDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (_) => ChangeNotifierProvider.value(
          value: Provider.of<CostRecordsViewModel>(context, listen: false),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const _AddCostDialogContent(),
          ),
        ),
  );
}

class _AddCostDialogContent extends StatefulWidget {
  const _AddCostDialogContent();
  @override
  State<_AddCostDialogContent> createState() => _AddCostDialogContentState();
}

class _AddCostDialogContentState extends State<_AddCostDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Feed';
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CostRecordsViewModel>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Cost Record',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => v!.isEmpty ? 'Description is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Amount is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items:
                  [
                        'Feed',
                        'Medicine/Vaccines',
                        'Utilities',
                        'Labor',
                        'Equipment Repair',
                        'Other',
                      ]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newCost = CostRecord(
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    costCategory: _category,
                    transactionDate: _date,
                  );
                  await viewModel.addCostRecord(newCost);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Save Cost'),
            ),
          ],
        ),
      ),
    );
  }
}
