// lib/models/cost_record_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CostRecord {
  final String? id;
  final String? batchId;
  final String costCategory;
  final double amount;
  final DateTime transactionDate;
  final String? description;

  CostRecord({
    this.id,
    this.batchId,
    required this.costCategory,
    required this.amount,
    required this.transactionDate,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'batch_id': batchId,
    'cost_category': costCategory,
    'amount': amount,
    'transaction_date': Timestamp.fromDate(transactionDate),
    'description': description,
  };

  factory CostRecord.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CostRecord(
      id: doc.id,
      batchId: data['batch_id'],
      costCategory: data['cost_category'],
      amount: data['amount'],
      transactionDate: (data['transaction_date'] as Timestamp).toDate(),
      description: data['description'],
    );
  }
}
