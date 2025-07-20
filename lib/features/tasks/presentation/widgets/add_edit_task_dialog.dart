import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/features/tasks/data/models/farm_task_model.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/core/utils/task_helpers.dart';
import '../view_models/task_board_view_model.dart';

void showAddEditTaskDialog(BuildContext context, {FarmTask? task}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder:
        (_) => ChangeNotifierProvider.value(
          value: Provider.of<TaskBoardViewModel>(context, listen: false),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _AddEditTaskDialogContent(task: task),
          ),
        ),
  );
}

class _AddEditTaskDialogContent extends StatefulWidget {
  final FarmTask? task;
  const _AddEditTaskDialogContent({this.task});

  @override
  State<_AddEditTaskDialogContent> createState() =>
      _AddEditTaskDialogContentState();
}

class _AddEditTaskDialogContentState extends State<_AddEditTaskDialogContent> {
  final _formKey = GlobalKey<FormState>();
  TaskType _selectedType = TaskType.custom;
  DateTime? _selectedDate;
  String? _selectedAssigneeId;
  String _selectedStatus = 'open';

  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _selectedType = widget.task!.taskType;
      _selectedDate = widget.task!.dueDate;
      _selectedAssigneeId = widget.task!.assignedToUserId;
      _selectedStatus = widget.task!.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskBoardViewModel>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditMode ? 'Edit Task' : 'Add New Task',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<TaskType>(
                value: _selectedType,
                items:
                    TaskType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.title),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(labelText: 'Task Type'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAssigneeId,
                items:
                    viewModel.users
                        .map(
                          (user) => DropdownMenuItem(
                            value: user.id,
                            child: Text(user.fullName),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedAssigneeId = val),
                decoration: const InputDecoration(labelText: 'Assign To'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate == null
                      ? 'Select Due Date'
                      : 'Due: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final updatedTask = FarmTask(
                          id: widget.task?.id ?? '',
                          taskType: _selectedType,
                          category: TaskCategory.operations,
                          status: _selectedStatus,
                          assignedToUserId: _selectedAssigneeId,
                          dueDate: _selectedDate,
                        );

                        if (isEditMode) {
                          viewModel.updateTask(updatedTask);
                        } else {
                          viewModel.addTask(updatedTask);
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
