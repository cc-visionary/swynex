import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { health, lifecycle, operations, feeding, inventory, unknown }

enum TaskType {
  vaccinate,
  administerTreatment,
  observeAnimal,
  weighPigs,
  move,
  logFarrowing,
  checkHeat,
  inseminateSow,
  checkPregnancy,
  clean,
  performMaintenance,
  logFeedUsage,
  receiveInventory,
  custom,
}

class FarmTask {
  final String id;
  final TaskType taskType; // The specific type for logic and icon mapping
  final TaskCategory category; // The high-level category for filtering
  final String status; // 'open', 'in_progress', 'completed', 'cancelled'

  final String? assignedToUserId;
  final DateTime? dueDate;
  final String? relatedToId; // Can be a pigId, batchId, or locationId
  final String? relatedToType; // 'pig', 'batch', 'location'
  final String? notes; // For any extra user-added comments

  FarmTask({
    required this.id,
    required this.taskType,
    required this.category,
    required this.status,
    this.assignedToUserId,
    this.dueDate,
    this.relatedToId,
    this.relatedToType,
    this.notes,
  });

  factory FarmTask.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmTask(
      id: doc.id,
      taskType: TaskType.values.firstWhere(
        (e) => e.name == data['taskType'],
        orElse: () => TaskType.custom,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TaskCategory.unknown,
      ),
      status: data['status'] ?? 'open',
      assignedToUserId: data['assignedToUserId'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      relatedToId: data['relatedToId'],
      relatedToType: data['relatedToType'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'taskType': taskType.name,
    'category': category.name,
    'status': status,
    'assignedToUserId': assignedToUserId,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'relatedToId': relatedToId,
    'relatedToType': relatedToType,
    'notes': notes,
  };
}
