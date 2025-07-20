
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/pigs_view_model.dart';

class PigListView extends StatelessWidget {
  const PigListView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PigsViewModel>();
    final pigs = viewModel.filteredPigs;

    if (pigs.isEmpty) {
      return const Center(
        child: Text('No pigs found. Try clearing your filters.'),
      );
    }

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
