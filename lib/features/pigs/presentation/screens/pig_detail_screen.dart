import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/features/health/data/models/health_log_model.dart';
import 'package:pig_lifecycle_crm/features/pigs/data/models/pig_model.dart';
import 'package:provider/provider.dart';
import '../view_models/pig_detail_view_model.dart';

class PigDetailScreen extends StatefulWidget {
  final String pigId;
  const PigDetailScreen({required this.pigId, super.key});

  @override
  State<PigDetailScreen> createState() => _PigDetailScreenState();
}

class _PigDetailScreenState extends State<PigDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PigDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Create the ViewModel instance, passing the pigId
    _viewModel = PigDetailViewModel(pigId: widget.pigId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose(); // Dispose the ViewModel
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel to the widget tree
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: StreamBuilder<Pig?>(
        // The main builder listens to the pig stream to get the title
        stream: _viewModel.pigStream,
        builder: (context, snapshot) {
          final pig = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                pig == null ? 'Loading...' : 'Profile: ${pig.farmTagId}',
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Info'),
                  Tab(text: 'Health'),
                  Tab(text: 'Breeding'),
                  Tab(text: 'Farrowing'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Each child is now a dedicated widget that can consume the ViewModel
                _buildInfoTab(pig),
                const _HealthLogTab(),
                const _BreedingCycleTab(),
                const Center(child: Text('Farrowing Records Tab')),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(Pig? pig) {
    if (pig == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      children: [
        ListTile(
          title: const Text('Farm Tag ID'),
          subtitle: Text(pig.farmTagId),
        ),
        ListTile(title: const Text('Status'), subtitle: Text(pig.status)),
        ListTile(title: const Text('Gender'), subtitle: Text(pig.gender)),
        // ... add other info fields
      ],
    );
  }
}

// Example Tab Widget for Health Logs
class _HealthLogTab extends StatelessWidget {
  const _HealthLogTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PigDetailViewModel>();
    return StreamBuilder<List<HealthLog>>(
      stream: viewModel.healthLogsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Center(child: Text('No health records found.'));

        final logs = snapshot.data!;
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return ListTile(
              title: Text(log.description),
              subtitle: Text(log.eventDate.toLocal().toString()),
            );
          },
        );
      },
    );
  }
}

// Example Tab Widget for Breeding Cycles
class _BreedingCycleTab extends StatelessWidget {
  const _BreedingCycleTab();

  @override
  Widget build(BuildContext context) {
    // ... similar to _HealthLogTab, but listens to viewModel.breedingCyclesStream ...
    return const Center(child: Text('Breeding Cycle History'));
  }
}
