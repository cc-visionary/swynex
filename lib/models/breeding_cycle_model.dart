// lib/models/breeding_cycle_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class BreedingCycle {
  final String? id;
  final String sowId;
  final String? boarId;
  final DateTime inseminationDate;
  final DateTime expectedFarrowingDate;
  final String status; // 'confirmed', 'completed', 'failed'
  final String? notes;

  BreedingCycle({
    this.id,
    required this.sowId,
    this.boarId,
    required this.inseminationDate,
    required this.expectedFarrowingDate,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'sow_id': sowId,
    'boar_id': boarId,
    'insemination_date': Timestamp.fromDate(inseminationDate),
    'expected_farrowing_date': Timestamp.fromDate(expectedFarrowingDate),
    'status': status,
    'notes': notes,
  };

  factory BreedingCycle.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return BreedingCycle(
      id: doc.id,
      sowId: data['sow_id'],
      boarId: data['boar_id'],
      inseminationDate: (data['insemination_date'] as Timestamp).toDate(),
      expectedFarrowingDate:
          (data['expected_farrowing_date'] as Timestamp).toDate(),
      status: data['status'],
      notes: data['notes'],
    );
  }
}
