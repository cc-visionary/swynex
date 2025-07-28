// lib/models/sale_record_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SaleRecord {
  final String? id;
  final String? batchId;
  final String? customerName;
  final DateTime saleDate;
  final int? quantity;
  final double? totalWeightKg;
  final double totalAmount;
  final String? notes;

  SaleRecord({
    this.id,
    this.batchId,
    this.customerName,
    required this.saleDate,
    this.quantity,
    this.totalWeightKg,
    required this.totalAmount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'batch_id': batchId,
    'customer_name': customerName,
    'sale_date': Timestamp.fromDate(saleDate),
    'quantity': quantity,
    'total_weight_kg': totalWeightKg,
    'total_amount': totalAmount,
    'notes': notes,
  };

  factory SaleRecord.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SaleRecord(
      id: doc.id,
      batchId: data['batch_id'],
      customerName: data['customer_name'],
      saleDate: (data['sale_date'] as Timestamp).toDate(),
      quantity: data['quantity'],
      totalWeightKg: data['total_weight_kg'],
      totalAmount: data['total_amount'],
      notes: data['notes'],
    );
  }
}
