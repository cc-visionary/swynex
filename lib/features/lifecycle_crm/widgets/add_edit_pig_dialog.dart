import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import 'package:pig_lifecycle_crm/utils/farm_data_constants.dart';
import '../view_models/pigs_view_model.dart';

void showAddEditPigDialog(BuildContext context, {Pig? pig}) {
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
            child: _AddEditPigDialogContent(pig: pig),
          ),
        ),
  );
}

class _AddEditPigDialogContent extends StatefulWidget {
  final Pig? pig;
  const _AddEditPigDialogContent({this.pig});

  @override
  State<_AddEditPigDialogContent> createState() =>
      _AddEditPigDialogContentState();
}

class _AddEditPigDialogContentState extends State<_AddEditPigDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _tagIdController = TextEditingController();
  final _breedController = TextEditingController();

  DateTime _birthDate = DateTime.now();
  String _gender = 'Female';
  String _status = 'Active';
  String? _selectedPenId;
  String? _damId;
  String? _sireId;

  bool get isEditMode => widget.pig != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final p = widget.pig!;
      _tagIdController.text = p.farmTagId;
      _birthDate = p.birthDate;
      _gender = p.gender;
      _status = p.status;
      _selectedPenId = p.currentPenId;
      _damId = p.damId;
      _sireId = p.sireId;
      _breedController.text = p.breed ?? '';
    }
  }

  @override
  void dispose() {
    _tagIdController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PigsViewModel>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditMode ? 'Edit Pig Details' : 'Add New Pig',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tagIdController,
                decoration: const InputDecoration(labelText: 'Farm Tag ID'),
                validator: (v) => v!.isEmpty ? 'Tag ID is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items:
                    FarmData.pigStatuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                items:
                    FarmData.pigGenders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                onChanged: (val) => setState(() => _gender = val!),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 16),
              // You can expand this to be a dropdown with FarmData.pigBreeds
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting the pen
              DropdownButtonFormField<String>(
                value: _selectedPenId,
                items:
                    viewModel.pens
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedPenId = val),
                decoration: const InputDecoration(labelText: 'Assign to Pen'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: theme.elevatedButtonTheme.style?.copyWith(
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 50),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final pigToSave = Pig(
                      id: widget.pig?.id,
                      farmTagId: _tagIdController.text,
                      birthDate: _birthDate,
                      gender: _gender,
                      status: _status,
                      breed: _breedController.text,
                      currentPenId: _selectedPenId,
                      damId: _damId,
                      sireId: _sireId,
                    );

                    if (isEditMode) {
                      await viewModel.updatePig(pigToSave);
                    } else {
                      await viewModel.addPig(pigToSave);
                    }
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                child: Text(isEditMode ? 'Save Changes' : 'Add Pig'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
