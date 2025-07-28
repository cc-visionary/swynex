import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/core/utils/farm_data_constants.dart';
import '../view_models/pigs_view_model.dart';

void showRegisterPurchaseDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
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
  final _costController = TextEditingController();

  String? _selectedGender;
  String? _selectedStatus;
  DateTime _selectedDateTime = DateTime.now();

  final List<PenAssignment> _assignments = [
    PenAssignment(penId: '', quantity: 0),
  ];
  final List<TextEditingController> _quantityControllers = [
    TextEditingController(),
  ];

  int get _totalPigsPurchased => int.tryParse(_countController.text) ?? 0;
  int get _totalPigsAssigned {
    return _quantityControllers.fold<int>(0, (sum, controller) {
      return sum + (int.tryParse(controller.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    for (final controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
    final viewModel = context.watch<PigsViewModel>();
    final theme = Theme.of(context);
    final remainingToAssign = _totalPigsPurchased - _totalPigsAssigned;

    final validGenders = FarmData.gendersByStatus[_selectedStatus] ?? [];

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
              value: _selectedStatus,
              hint: const Text('Initial Status'),
              items:
                  FarmData.purchaseStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    _selectedStatus = val;
                    final newValidGenders =
                        FarmData.gendersByStatus[_selectedStatus] ?? [];
                    if (newValidGenders.length == 1) {
                      _selectedGender = newValidGenders.first;
                    } else {
                      // This is the important part to reset the selection
                      _selectedGender = null;
                    }
                  }),
              decoration: const InputDecoration(labelText: 'Initial Status'),
              validator: (v) => v == null ? 'Please select a status' : null,
            ),
            const Divider(height: 32),
            Text('Pen Assignments', style: theme.textTheme.titleMedium),
            Text(
              'Remaining to assign: $remainingToAssign',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        hint: const Text('Select Pen'),
                        items:
                            viewModel.pens
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(
                              () =>
                                  _assignments[index] = PenAssignment(
                                    penId: val!,
                                    quantity: 0,
                                  ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityControllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (_) =>
                                setState(() {}), // Rebuild for remaining count
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          index == 0
                              ? null
                              : () => setState(() {
                                _assignments.removeAt(index);
                                _quantityControllers.removeAt(index).dispose();
                              }),
                    ),
                  ],
                );
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Another Pen'),
              onPressed:
                  () => setState(() {
                    _assignments.add(PenAssignment(penId: '', quantity: 0));
                    _quantityControllers.add(TextEditingController());
                  }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: const Text('Gender'),
              disabledHint: const Text('Gender auto-selected'),
              items:
                  validGenders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
              onChanged:
                  (_selectedStatus != null && validGenders.length == 1)
                      ? null
                      : (val) => setState(() => _selectedGender = val),
              decoration: const InputDecoration(labelText: 'Gender'),
              validator: (v) => v == null ? 'Please select a gender' : null,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost',
                  prefixText: '₱ ', // Philippine Peso symbol
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
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
              onPressed:
                  (remainingToAssign != 0 || _totalPigsPurchased == 0)
                      ? null
                      : () async {
                        if (_formKey.currentState!.validate()) {
                          // Update the assignment objects with the final quantities
                          for (int i = 0; i < _assignments.length; i++) {
                            _assignments[i] = PenAssignment(
                              penId: _assignments[i].penId,
                              quantity: int.parse(_quantityControllers[i].text),
                            );
                          }
                          await viewModel.addPurchaseBatch(
                            assignments:
                                _assignments
                                    .where((a) => a.quantity > 0)
                                    .toList(),
                            totalCost: double.parse(_costController.text),
                            gender: _selectedGender!,
                            status: _selectedStatus!,
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
