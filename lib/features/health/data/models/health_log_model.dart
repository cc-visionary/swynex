// lib/models/health_log_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class HealthLog {
  final String? id;
  final String? pigId;
  final String? batchId;
  final String logType; // 'vaccination', 'treatment', 'sickness_observation'
  final DateTime eventDate;
  final String description;
  final String? medicineId;
  final String? dosage;
  final String recordedByUserId;
  final String? mediaUrl;

  HealthLog({
    this.id,
    this.pigId,
    this.batchId,
    required this.logType,
    required this.eventDate,
    required this.description,
    this.medicineId,
    this.dosage,
    required this.recordedByUserId,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() => {
    'pig_id': pigId,
    'batch_id': batchId,
    'log_type': logType,
    'event_date': Timestamp.fromDate(eventDate),
    'description': description,
    'medicine_id': medicineId,
    'dosage': dosage,
    'recorded_by_user_id': recordedByUserId,
    'media_url': mediaUrl,
  };

  factory HealthLog.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return HealthLog(
      id: doc.id,
      pigId: data['pig_id'],
      batchId: data['batch_id'],
      logType: data['log_type'],
      eventDate: (data['event_date'] as Timestamp).toDate(),
      description: data['description'],
      medicineId: data['medicine_id'],
      dosage: data['dosage'],
      recordedByUserId: data['recorded_by_user_id'],
      mediaUrl: data['media_url'],
    );
  }
}
