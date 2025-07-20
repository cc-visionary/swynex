
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/pig_batch_model.dart';
import '../view_models/pigs_view_model.dart';

class PigBatchView extends StatelessWidget {
  const PigBatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PigsViewModel>();
    final batches = viewModel.filteredBatches;
    final allPigs = viewModel.filteredPigs;

    if (batches.isEmpty) {
      return const Center(child: Text('No batches found.'));
    }

    return ListView.builder(
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        final pigsInBatch =
            allPigs.where((p) => p.batchId == batch.id).toList();
        final selectedInBatchCount =
            pigsInBatch.where((p) => viewModel.isPigSelected(p.id!)).length;

        return ExpansionTile(
          leading: Checkbox(
            value:
                selectedInBatchCount == pigsInBatch.length &&
                pigsInBatch.isNotEmpty,
            tristate:
                selectedInBatchCount > 0 &&
                selectedInBatchCount < pigsInBatch.length,
            onChanged: (_) => viewModel.toggleBatchSelection(pigsInBatch),
          ),
          title: Text(
            batch.batchName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${pigsInBatch.length} Pigs'),
          children:
              pigsInBatch
                  .map(
                    (pig) => ListTile(
                      onTap: () => context.push('/pigs/${pig.id}'),
                      leading: Checkbox(
                        value: viewModel.isPigSelected(pig.id!),
                        onChanged: (_) => viewModel.togglePigSelection(pig.id!),
                      ),
                      title: Text(pig.farmTagId),
                      subtitle: Text('Status: ${pig.status}'),
                    ),
                  )
                  .toList(),
          trailing: _buildBatchMoreMenu(context, batch, viewModel),
        );
      },
    );
  }
}

Widget _buildBatchMoreMenu(
  BuildContext context,
  PigBatch batch,
  PigsViewModel viewModel,
) {
  return PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert),
    onSelected: (value) async {
      if (value == 'delete_batch') {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: Text(
                  'Delete batch "${batch.batchName}" and all pigs within it? This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete Batch'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
        );
        if (confirm == true) {
          viewModel.deleteBatchAndPigs(batch);
        }
      }
    },
    itemBuilder:
        (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'delete_batch',
            child: ListTile(
              leading: Icon(Icons.delete_sweep_outlined, color: Colors.red),
              title: Text(
                'Delete Entire Batch',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
  );
}
