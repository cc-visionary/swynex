// lib/models/weight_record_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WeightRecord {
  final String? id;
  final String? pigId;
  final String? batchId;
  final double weightKg;
  final DateTime weighInDate;

  WeightRecord({
    this.id,
    this.pigId,
    this.batchId,
    required this.weightKg,
    required this.weighInDate,
  });

  Map<String, dynamic> toJson() => {
    'pig_id': pigId,
    'batch_id': batchId,
    'weight_kg': weightKg,
    'weigh_in_date': Timestamp.fromDate(weighInDate),
  };

  factory WeightRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return WeightRecord(
      id: doc.id,
      pigId: data['pig_id'],
      batchId: data['batch_id'],
      weightKg: data['weight_kg'],
      weighInDate: (data['weigh_in_date'] as Timestamp).toDate(),
    );
  }
}
