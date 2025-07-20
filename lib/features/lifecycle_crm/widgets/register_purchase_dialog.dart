import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import 'package:pig_lifecycle_crm/utils/farm_data_constants.dart';
import '../view_models/pigs_view_model.dart';

void showRegisterPurchaseDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (_) => ChangeNotifierProvider.value(
          value: Provider.of<PigsViewModel>(context, listen: false),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const _RegisterPurchaseDialogContent(),
          ),
        ),
  );
}

class _RegisterPurchaseDialogContent extends StatefulWidget {
  const _RegisterPurchaseDialogContent();
  @override
  State<_RegisterPurchaseDialogContent> createState() =>
      _RegisterPurchaseDialogContentState();
}

class _RegisterPurchaseDialogContentState
    extends State<_RegisterPurchaseDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _countController = TextEditingController();
  String? _selectedGender = 'Female';
  String? _selectedStatus = 'Grower';
  String? _selectedPenId;
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use .watch here so the dropdown updates when location data is loaded
    final viewModel = context.watch<PigsViewModel>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Register New Purchase', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextFormField(
              controller: _countController,
              decoration: const InputDecoration(labelText: 'Number of Pigs'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Please enter a count' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items:
                  FarmData.pigGenders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items:
                  FarmData.pigStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedStatus = val),
              decoration: const InputDecoration(labelText: 'Initial Status'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPenId,
              hint: const Text('Assign to Pen'),
              // Build the items from the synchronous list
              items:
                  viewModel.pens
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedPenId = val),
              decoration: const InputDecoration(labelText: 'Assign to Pen'),
              validator: (v) => v == null ? 'Please select a pen' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Purchase Date & Time'),
              subtitle: Text(
                DateFormat('yyyy-MM-dd – hh:mm a').format(_selectedDateTime),
              ),
              onTap: () => _selectDateTime(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await viewModel.addPurchaseBatch(
                    numberOfPigs: int.parse(_countController.text),
                    gender: _selectedGender!,
                    status: _selectedStatus!,
                    penId: _selectedPenId!,
                    purchaseDate: _selectedDateTime,
                  );
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Save Purchase'),
            ),
          ],
        ),
      ),
    );
  }
}
