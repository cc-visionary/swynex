import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/pigs_view_model.dart';

void showLogFarrowingDialog(BuildContext context) {
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
            child: const _LogFarrowingDialogContent(),
          ),
        ),
  );
}

class _LogFarrowingDialogContent extends StatefulWidget {
  const _LogFarrowingDialogContent();

  @override
  State<_LogFarrowingDialogContent> createState() =>
      _LogFarrowingDialogContentState();
}

class _LogFarrowingDialogContentState
    extends State<_LogFarrowingDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _pigletCountController = TextEditingController();
  String? _selectedSowId;
  String? _selectedBoarId;
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
    final viewModel =
        context
            .watch<
              PigsViewModel
            >(); // Use watch to get updates to the sows list
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log New Litter', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedSowId,
              hint: const Text('Select Mother Sow'),
              // Use the new, more accurate list of sows
              items:
                  viewModel.farrowingSows
                      .map(
                        (sow) => DropdownMenuItem(
                          value: sow.id,
                          child: Text(sow.farmTagId),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedSowId = val),
              decoration: const InputDecoration(labelText: 'Mother Sow'),
              validator: (v) => v == null ? 'Please select a sow' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Birth Date & Time'),
              subtitle: Text(
                DateFormat('yyyy-MM-dd – hh:mm a').format(_selectedDateTime),
              ),
              onTap: () => _selectDateTime(context),
            ),
            TextFormField(
              controller: _pigletCountController,
              decoration: const InputDecoration(
                labelText: 'Number of Live Piglets',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a count';
                }
                final count = int.tryParse(value);
                if (count == null) {
                  return 'Please enter a valid number';
                }
                if (count <= 0) {
                  return 'Please enter a number greater than zero';
                }
                return null; // Return null if the input is valid
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBoarId,
              hint: const Text('Select Sire (Optional)'),
              items:
                  viewModel.boars
                      .map(
                        (boar) => DropdownMenuItem(
                          value: boar.id,
                          child: Text(boar.farmTagId),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedBoarId = val),
              decoration: const InputDecoration(labelText: 'Sire (Optional)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await viewModel.addLitter(
                    numberOfPiglets: int.parse(_pigletCountController.text),
                    damId: _selectedSowId!,
                    sireId: _selectedBoarId,
                    birthDate: _selectedDateTime,
                  );
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Save Litter'),
            ),
          ],
        ),
      ),
    );
  }
}
