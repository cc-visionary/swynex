import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:pig_lifecycle_crm/features/lifecycle_crm/widgets/filter_panel.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import 'package:pig_lifecycle_crm/features/auth/providers/auth_provider.dart';
import '../view_models/pigs_view_model.dart';
import '../widgets/add_edit_pig_dialog.dart';
import '../widgets/log_farrowing_dialog.dart';
import '../widgets/register_purchase_dialog.dart';

class PigsListScreen extends StatelessWidget {
  const PigsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel for this feature, getting the farmId from the AuthProvider
    return ChangeNotifierProvider(
      create:
          (_) => PigsViewModel(
            "farm_id_placeholder",
          ), // Replace with a real farmId later
      child: const _PigsListView(),
    );
  }
}

class _PigsListView extends StatelessWidget {
  const _PigsListView();

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds the UI when notifyListeners() is called in the ViewModel
    return Consumer<PigsViewModel>(
      builder: (context, viewModel, child) {
        final hasSelection = viewModel.selectedPigIds.isNotEmpty;
        final isBatchView = viewModel.viewMode == PigViewMode.batch;

        return Scaffold(
          appBar: HomeAppBar(
            title:
                hasSelection
                    ? '${viewModel.selectedPigIds.length} Selected'
                    : 'Pigs',
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filter',
                onPressed: () => showFilterPanel(context),
              ),
              IconButton(
                icon: Icon(
                  isBatchView ? Icons.list : Icons.account_tree_outlined,
                ),
                tooltip: 'Change View',
                onPressed: viewModel.toggleViewMode,
              ),
            ],
          ),
          body: isBatchView ? const _BatchView() : const _ListView(),
          floatingActionButton:
              hasSelection
                  ? _buildSelectionActions(context, viewModel)
                  : _buildDefaultActions(context),
        );
      },
    );
  }

  // Helper for the default SpeedDial
  Widget _buildDefaultActions(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.child_friendly),
          label: 'Log Farrowing',
          onTap: () => showLogFarrowingDialog(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.shopping_cart),
          label: 'Register Purchase',
          onTap: () => showRegisterPurchaseDialog(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.person_add_alt_1),
          label: 'Add Single Pig',
          onTap: () => showAddEditPigDialog(context),
        ),
      ],
    );
  }

  // Helper for the contextual actions when pigs are selected
  Widget _buildSelectionActions(BuildContext context, PigsViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'deleteBtn',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: Text(
                      'Are you sure you want to delete ${viewModel.selectedPigIds.length} pig(s)?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          viewModel.deleteSelectedPigs();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
            );
          },
          label: const Text('Delete'),
          icon: const Icon(Icons.delete_outline),
          backgroundColor: Colors.red,
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          heroTag: 'clearBtn',
          onPressed: viewModel.clearSelection,
          child: const Icon(Icons.close),
          mini: true,
          backgroundColor: Colors.grey[700],
        ),
      ],
    );
  }
}

// --- WIDGET FOR THE BATCH VIEW ---
class _BatchView extends StatelessWidget {
  const _BatchView();
  @override
  Widget build(BuildContext context) {
    // .watch listens for changes from notifyListeners()
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
        // Show a confirmation dialog before deleting the entire batch
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

// --- WIDGET FOR THE SIMPLE LIST VIEW ---
class _ListView extends StatelessWidget {
  const _ListView();
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PigsViewModel>();
    final pigs = viewModel.filteredPigs;

    if (pigs.isEmpty)
      return const Center(
        child: Text('No pigs found. Try clearing your filters.'),
      );

    return ListView.builder(
      itemCount: pigs.length,
      itemBuilder: (context, index) {
        final pig = pigs[index];
        return ListTile(
          onTap: () => context.push('/pigs/${pig.id}'),
          leading: Checkbox(
            value: viewModel.isPigSelected(pig.id!),
            onChanged: (_) => viewModel.togglePigSelection(pig.id!),
          ),
          title: Text(
            pig.farmTagId,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Status: ${pig.status}'),
        );
      },
    );
  }
}
