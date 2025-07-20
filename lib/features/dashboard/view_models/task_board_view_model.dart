import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import 'package:pig_lifecycle_crm/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';

class TaskBoardViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // State for the real user list
  List<AppUser> _allUsers = [];
  List<AppUser> get users => _allUsers;
  StreamSubscription? _usersSubscription;

  // Use BehaviorSubject to cache and broadcast the task list
  final _tasksSubject = BehaviorSubject<List<FarmTask>>();

  // Public streams for the UI, derived from the subject
  Stream<List<FarmTask>> get openTasksStream => _tasksSubject.stream.map(
    (tasks) => tasks.where((t) => t.status == 'open').toList(),
  );

  Stream<List<FarmTask>> get inProgressTasksStream => _tasksSubject.stream.map(
    (tasks) => tasks.where((t) => t.status == 'in_progress').toList(),
  );

  Stream<List<FarmTask>> get doneTasksStream => _tasksSubject.stream.map(
    (tasks) => tasks.where((t) => t.status == 'completed').toList(),
  );

  TaskBoardViewModel() {
    // Pipe the Firestore data directly into our subjects
    _firestoreService.getTasksStream().pipe(_tasksSubject);
    _usersSubscription = _firestoreService.getUsersStream().listen((users) {
      _allUsers = users;
      notifyListeners(); // Notify UI that the user list for the dropdown is ready
    });
  }

  @override
  void dispose() {
    _tasksSubject.close();
    _usersSubscription?.cancel();
    super.dispose();
  }

  String getAssigneeName(String? userId) {
    if (userId == null) return 'Unassigned';
    return _allUsers
        .firstWhere(
          (u) => u.id == userId,
          orElse:
              () => AppUser(id: '', fullName: 'Unknown', email: '', role: ''),
        )
        .fullName;
  }

  Future<void> addTask(FarmTask task) async {
    final taskData = task.toJson();
    await _firestoreService.addTask(taskData);
  }

  Future<void> updateTask(FarmTask task) async {
    await _firestoreService.updateTask(task.id, task.toJson());
  }
}
