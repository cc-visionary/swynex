
import 'package:flutter/material.dart';

import '../view_models/pigs_view_model.dart';

class SelectionActionsFab extends StatelessWidget {
  final PigsViewModel viewModel;

  const SelectionActionsFab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
