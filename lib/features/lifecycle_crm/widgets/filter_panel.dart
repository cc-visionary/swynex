import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import 'package:pig_lifecycle_crm/utils/farm_data_constants.dart';
import '../view_models/pigs_view_model.dart';

void showFilterPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder:
        (_) => ChangeNotifierProvider.value(
          value: Provider.of<PigsViewModel>(context, listen: false),
          child: const _FilterPanelContent(),
        ),
  );
}

class _FilterPanelContent extends StatefulWidget {
  const _FilterPanelContent();
  @override
  State<_FilterPanelContent> createState() => _FilterPanelContentState();
}

class _FilterPanelContentState extends State<_FilterPanelContent> {
  // Temporary state for the panel
  Set<String> _tempBuildingIds = {};
  Set<String> _tempRoomIds = {};
  Set<String> _tempPenIds = {};
  Set<String> _tempGenders = {};
  Set<String> _tempBreeds = {};

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PigsViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Pigs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildMultiSelectTile<FarmLocation>(
              context: context,
              title: 'Buildings',
              options: viewModel.buildings,
              selectedOptions: _tempBuildingIds,
              onChanged:
                  (newSelection) =>
                      setState(() => _tempBuildingIds = newSelection),
            ),
            _buildMultiSelectTile<FarmLocation>(
              context: context,
              title: 'Rooms',
              options: viewModel.getRoomsInBuilding(_tempBuildingIds),
              selectedOptions: _tempRoomIds,
              onChanged:
                  (newSelection) => setState(() => _tempRoomIds = newSelection),
            ),
            _buildMultiSelectTile<FarmLocation>(
              context: context,
              title: 'Pens',
              options: viewModel.getPensInRoom(_tempRoomIds),
              selectedOptions: _tempPenIds,
              onChanged:
                  (newSelection) => setState(() => _tempPenIds = newSelection),
            ),
            _buildMultiSelectTile<String>(
              context: context,
              title: 'Genders',
              options: FarmData.pigGenders,
              selectedOptions: _tempGenders,
              onChanged:
                  (newSelection) => setState(() => _tempGenders = newSelection),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    viewModel.clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear All'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    viewModel.applyFilters(
                      buildingIds: _tempBuildingIds,
                      roomIds: _tempRoomIds,
                      penIds: _tempPenIds,
                      genders: _tempGenders,
                      breeds: _tempBreeds,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build a consistent tile for opening the multi-select dialog
  Widget _buildMultiSelectTile<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required Set<String> selectedOptions,
    required ValueChanged<Set<String>> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        selectedOptions.isEmpty ? 'All' : '${selectedOptions.length} selected',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await _showMultiSelectDialog<T>(
          context,
          title,
          options,
          selectedOptions,
        );
        if (result != null) {
          onChanged(result);
        }
      },
    );
  }

  // The actual multi-select dialog with checkboxes
  Future<Set<String>?> _showMultiSelectDialog<T>(
    BuildContext context,
    String title,
    List<T> options,
    Set<String> initialSelection,
  ) {
    return showDialog<Set<String>>(
      context: context,
      builder: (context) {
        final tempSelection = Set<String>.from(initialSelection);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select $title'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    // Handle both FarmLocation and String types
                    final id =
                        option is FarmLocation ? option.id : option as String;
                    final name =
                        option is FarmLocation ? option.name : option as String;
                    final isSelected = tempSelection.contains(id);

                    return CheckboxListTile(
                      title: Text(name),
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            tempSelection.add(id);
                          } else {
                            tempSelection.remove(id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(tempSelection),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
