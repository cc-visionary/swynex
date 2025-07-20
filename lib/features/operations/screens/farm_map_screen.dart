import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/models/farm_location_model.dart';
import 'package:provider/provider.dart';

import '../view_models/farm_map_view_model.dart';

class FarmMapScreen extends StatelessWidget {
  const FarmMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FarmMapViewModel(),
      child: const _FarmMapView(),
    );
  }
}

class _FarmMapView extends StatelessWidget {
  const _FarmMapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Map')),
      body: Consumer<FarmMapViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.locations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final buildings =
              viewModel.locations.where((l) => l.type == 'building').toList();

          return ListView.builder(
            itemCount: buildings.length,
            itemBuilder: (context, index) {
              final building = buildings[index];
              return _buildBuilding(context, viewModel, building);
            },
          );
        },
      ),
    );
  }

  Widget _buildBuilding(
    BuildContext context,
    FarmMapViewModel viewModel,
    FarmLocation building,
  ) {
    final rooms =
        viewModel.locations.where((l) => l.parentId == building.id).toList();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          building.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${viewModel.getAggregatedPigCountForLocation(building)} Pigs',
        ),
        children:
            rooms.map((room) => _buildRoom(context, viewModel, room)).toList(),
      ),
    );
  }

  Widget _buildRoom(
    BuildContext context,
    FarmMapViewModel viewModel,
    FarmLocation room,
  ) {
    final pens =
        viewModel.locations.where((l) => l.parentId == room.id).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: Text(room.name),
        subtitle: Text(
          '${viewModel.getAggregatedPigCountForLocation(room)} Pigs',
        ),
        children:
            pens.map((pen) => _buildPen(context, viewModel, pen)).toList(),
      ),
    );
  }

  Widget _buildPen(
    BuildContext context,
    FarmMapViewModel viewModel,
    FarmLocation pen,
  ) {
    return ListTile(
      title: Text(pen.name),
      subtitle: Text('${viewModel.getAggregatedPigCountForLocation(pen)} Pigs'),
      trailing: Text(
        '${viewModel.getAggregatedTaskCountForLocation(pen)} Tasks',
      ),
    );
  }
}
