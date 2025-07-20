import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/features/lifecycle_crm/widgets/add_edit_pig_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import '../view_models/pigs_view_model.dart';

class PigProfileScreen extends StatelessWidget {
  final String pigId;
  const PigProfileScreen({required this.pigId, super.key});

  @override
  Widget build(BuildContext context) {
    // Use a StreamBuilder to get real-time updates for this one pig
    return Consumer<PigsViewModel>(
      builder: (context, viewModel, child) {
        // Find the pig from the ViewModel's already-loaded list of all pigs
        final pig = viewModel.allPigs.firstWhere(
          // Assuming you add a getter `List<Pig> get allPigs => _pigsSubject.value;`
          (p) => p.id == pigId,
          orElse:
              () => Pig(
                farmTagId: 'Not Found',
                birthDate: DateTime.now(),
                gender: 'Unknown',
                status: 'Unknown',
              ),
        );

        if (pig.id == null) {
          return const Scaffold(body: Center(child: Text('Pig not found.')));
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
    );
  }
}
