import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/widgets/home_app_bar.dart';
import '../view_models/pigs_view_model.dart';
import '../widgets/default_actions_fab.dart';
import '../widgets/filter_panel.dart';
import '../widgets/pig_batch_view.dart';
import '../widgets/pig_list_view.dart';
import '../widgets/selection_actions_fab.dart';

class PigsListScreen extends StatelessWidget {
  const PigsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PigsViewModel("farm_id_placeholder"),
      child: const _PigsListView(),
    );
  }
}

class _PigsListView extends StatelessWidget {
  const _PigsListView();

  @override
  Widget build(BuildContext context) {
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
          body: isBatchView ? const PigBatchView() : const PigListView(),
          floatingActionButton:
              hasSelection
                  ? SelectionActionsFab(viewModel: viewModel)
                  : const DefaultActionsFab(),
        );
      },
    );
  }
}
