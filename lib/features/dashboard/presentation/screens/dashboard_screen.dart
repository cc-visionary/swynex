import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(title: 'Dashboard'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Row of KPI Cards
          Row(
            children: [
              _buildKpiCard('Total Pigs', '1,234', Icons.pets, Colors.blue),
              const SizedBox(width: 16),
              _buildKpiCard(
                'Sows Due',
                '12',
                Icons.pregnant_woman,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildKpiCard(
                'Low Feed',
                '2 Alerts',
                Icons.warning_amber_rounded,
                Colors.red,
              ),
              const SizedBox(width: 16),
              _buildKpiCard('Open Tasks', '8', Icons.task_alt, Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for a chart
          Text(
            'Sales Overview Chart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text('Chart will be here'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
