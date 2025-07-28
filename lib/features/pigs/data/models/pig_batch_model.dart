// lib/models/pig_batch_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PigBatch {
  final String? id;
  final String batchName;
  final DateTime creationDate;
  final String? notes;

  PigBatch({
    this.id,
    required this.batchName,
    required this.creationDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'batchName': batchName,
    'creationDate': Timestamp.fromDate(creationDate),
    'notes': notes,
  };

  factory PigBatch.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PigBatch(
      id: doc.id,
      batchName: data['batchName'],
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }
}
