import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/app/widgets/home_app_bar.dart';
import 'package:pig_lifecycle_crm/models/farm_task_model.dart';
import 'package:pig_lifecycle_crm/utils/task_helpers.dart';
import '../view_models/task_board_view_model.dart';
import '../widgets/add_edit_task_dialog.dart';

class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  late final TaskBoardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TaskBoardViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _TaskBoardView(),
    );
  }
}

class _TaskBoardView extends StatefulWidget {
  const _TaskBoardView();

  @override
  State<_TaskBoardView> createState() => _TaskBoardViewState();
}

class _TaskBoardViewState extends State<_TaskBoardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TaskBoardViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: HomeAppBar(
        title: 'Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => showAddEditTaskDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'In Progress'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskList(stream: viewModel.openTasksStream),
          _TaskList(stream: viewModel.inProgressTasksStream),
          _TaskList(stream: viewModel.doneTasksStream),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final Stream<List<FarmTask>> stream;
  const _TaskList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FarmTask>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks in this category.'));
        }
        final tasks = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskCard(task: task);
          },
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final FarmTask task;
  const _TaskCard({required this.task});

  String _getDueDateText(DateTime? dueDate) {
    if (dueDate == null) return 'NO DUE DATE';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference == 0) return 'DUE TODAY';
    if (difference == 1) return 'DUE TOMORROW';
    if (difference > 1) return 'DUE IN $difference DAYS';
    return 'OVERDUE';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TaskBoardViewModel>();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => showAddEditTaskDialog(context, task: task),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Icon(task.taskType.icon)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getDueDateText(task.dueDate)),
                    const SizedBox(height: 6),
                    Text(
                      task.taskType.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Assignee: ${viewModel.getAssigneeName(task.assignedToUserId)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
