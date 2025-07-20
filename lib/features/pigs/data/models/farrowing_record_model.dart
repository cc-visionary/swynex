// lib/models/farrowing_record_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FarrowingRecord {
  final String? id;
  final String cycleId;
  final DateTime farrowingDate;
  final int livePiglets;
  final int stillbornPiglets;
  final String? notes;

  FarrowingRecord({
    this.id,
    required this.cycleId,
    required this.farrowingDate,
    required this.livePiglets,
    required this.stillbornPiglets,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'cycle_id': cycleId,
    'farrowing_date': Timestamp.fromDate(farrowingDate),
    'live_piglets': livePiglets,
    'stillborn_piglets': stillbornPiglets,
    'notes': notes,
  };

  factory FarrowingRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FarrowingRecord(
      id: doc.id,
      cycleId: data['cycle_id'],
      farrowingDate: (data['farrowing_date'] as Timestamp).toDate(),
      livePiglets: data['live_piglets'],
      stillbornPiglets: data['stillborn_piglets'],
      notes: data['notes'],
    );
  }
}
