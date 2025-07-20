// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'owner', 'manager', 'worker', 'vet'

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AppUser.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'worker',
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'role': role,
  };
}
