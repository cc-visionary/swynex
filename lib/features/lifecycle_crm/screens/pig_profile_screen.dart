import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/pig_model.dart';
import '../view_models/pig_profile_view_model.dart';
import '../widgets/add_edit_pig_dialog.dart';

class PigProfileScreen extends StatelessWidget {
  final String pigId;
  const PigProfileScreen({required this.pigId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PigProfileViewModel(pigId),
      child: Consumer<PigProfileViewModel>(
        builder: (context, viewModel, child) {
          final pig = viewModel.pig;

          if (pig == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Profile: ${pig.farmTagId}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showAddEditPigDialog(context, pig: pig),
                ),
              ],
            ),
            body: ListView(
              children: [
                ListTile(
                  title: const Text('Farm Tag ID'),
                  subtitle: Text(pig.farmTagId),
                ),
                ListTile(title: const Text('Status'), subtitle: Text(pig.status)),
                ListTile(title: const Text('Gender'), subtitle: Text(pig.gender)),
                ListTile(
                  title: const Text('Breed'),
                  subtitle: Text(pig.breed ?? 'N/A'),
                ),
                ListTile(
                  title: const Text('Birth Date'),
                  subtitle: Text(pig.birthDate.toLocal().toString()),
                ),
                ListTile(
                  title: const Text('Current Pen ID'),
                  subtitle: Text(pig.currentPenId ?? 'Not Assigned'),
                ),
                ListTile(
                  title: const Text('Batch ID'),
                  subtitle: Text(pig.batchId ?? 'N/A'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}