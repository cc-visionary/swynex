import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import '../view_models/farm_management_view_model.dart';
import '../widgets/add_edit_location_dialog.dart';

class FarmManagementScreen extends StatelessWidget {
  const FarmManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FarmManagementViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Farm Management')),
        body: Consumer<FarmManagementViewModel>(
          builder: (context, viewModel, _) {
            final buildings = viewModel.buildings;
            if (buildings.isEmpty) {
              return const Center(
                child: Text('No buildings found. Add one to get started.'),
              );
            }
            return ListView.builder(
              itemCount: buildings.length,
              itemBuilder: (context, index) {
                final building = buildings[index];
                final rooms = viewModel.getRoomsInBuilding(building.id);
                return ExpansionTile(
                  leading: const Icon(Icons.business_rounded),
                  title: Text(
                    building.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${rooms.length} Room(s)'),
                  trailing: _buildMoreMenu(context, building, viewModel),
                  children: [
                    ...rooms.map((room) {
                      final pens = viewModel.getPensInRoom(room.id);
                      return ExpansionTile(
                        tilePadding: const EdgeInsets.only(left: 32),
                        leading: const Icon(Icons.meeting_room_outlined),
                        title: Text(room.name),
                        subtitle: Text('${pens.length} Pen(s)'),
                        trailing: _buildMoreMenu(context, room, viewModel),
                        children: [
                          ...pens
                              .map(
                                (pen) => ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 48,
                                  ),
                                  leading: const Icon(Icons.grid_4x4_rounded),
                                  title: Text(pen.name),
                                  // --- UPDATE: Added dropdown menu for pens ---
                                  trailing: _buildMoreMenu(
                                    context,
                                    pen,
                                    viewModel,
                                  ),
                                ),
                              )
                              .toList(),
                          ListTile(
                            contentPadding: const EdgeInsets.only(left: 48),
                            leading: const Icon(Icons.add),
                            title: const Text(
                              'Add Pen(s)',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            onTap: () async {
                              final names = await showAddLocationsDialog(
                                context,
                                title: 'Add Pen(s) to ${room.name}',
                              );
                              if (names != null && names.isNotEmpty) {
                                viewModel.addLocations(
                                  names: names,
                                  type: 'pen',
                                  parentId: room.id,
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }).toList(),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 32),
                      leading: const Icon(Icons.add),
                      title: const Text(
                        'Add Room(s)',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onTap: () async {
                        final names = await showAddLocationsDialog(
                          context,
                          title: 'Add Room(s) to ${building.name}',
                        );
                        if (names != null && names.isNotEmpty) {
                          viewModel.addLocations(
                            names: names,
                            type: 'room',
                            parentId: building.id,
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              child: const Icon(Icons.add_business_outlined),
              tooltip: 'Add Building',
              onPressed: () async {
                final viewModel = context.read<FarmManagementViewModel>();
                final names = await showAddLocationsDialog(
                  context,
                  title: 'Add New Building(s)',
                );
                if (names != null && names.isNotEmpty) {
                  viewModel.addLocations(names: names, type: 'building');
                }
              },
            );
          },
        ),
      ),
    );
  }

  // --- NEW: Helper function to build the dropdown menu ---
  Widget _buildMoreMenu(
    BuildContext context,
    FarmLocation location,
    FarmManagementViewModel viewModel,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'edit') {
          // --- UPDATE: Call the new dialog designed for editing ---
          final newName = await showEditLocationDialog(
            context,
            title: 'Edit ${location.name}',
            initialValue: location.name, // Pass the current name to the dialog
          );
          if (newName != null && newName.isNotEmpty) {
            viewModel.updateLocationName(location.id, newName);
          }
        } else if (value == 'delete') {
          // The delete logic remains the same
          final confirm = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content: Text(
                    'Delete "${location.name}" and all it\'s child location? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
          );
          if (confirm == true) {
            viewModel.deleteLocation(location.id);
          }
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit Name'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
    );
  }
}
