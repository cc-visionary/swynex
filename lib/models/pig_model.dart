// lib/models/pig_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Pig {
  final String? id;
  final String farmTagId;
  final String gender;
  final String? breed;
  final DateTime birthDate;
  final String? damId;
  final String? sireId;
  final String? batchId;
  final String? currentPenId; // FK to FarmLocation
  final String status;
  final String? cullingReason;

  Pig({
    this.id,
    required this.farmTagId,
    required this.gender,
    this.breed,
    required this.birthDate,
    this.damId,
    this.sireId,
    this.batchId,
    this.currentPenId,
    required this.status,
    this.cullingReason,
  });

  Map<String, dynamic> toJson() => {
    'farm_tag_id': farmTagId,
    'gender': gender,
    'breed': breed,
    'birth_date': Timestamp.fromDate(birthDate),
    'dam_id': damId,
    'sire_id': sireId,
    'batch_id': batchId,
    'currentPenId': currentPenId,
    'status': status,
    'culling_reason': cullingReason,
  };

  factory Pig.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Pig(
      id: doc.id,
      farmTagId: data['farm_tag_id'],
      gender: data['gender'],
      breed: data['breed'],
      birthDate: (data['birth_date'] as Timestamp).toDate(),
      damId: data['dam_id'],
      sireId: data['sire_id'],
      batchId: data['batch_id'],
      currentPenId: data['currentPenId'],
      status: data['status'],
      cullingReason: data['culling_reason'],
    );
  }
}
