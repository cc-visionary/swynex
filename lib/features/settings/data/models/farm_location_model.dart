import 'package:cloud_firestore/cloud_firestore.dart';

class FarmLocation {
  final String id;
  final String name;
  final String type; // 'building', 'room', 'pen'
  final String? parentId; // ID of the parent (e.g., a pen's parent is a room)

  FarmLocation({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
  });

  factory FarmLocation.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmLocation(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'pen',
      parentId: data['parentId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'parentId': parentId,
  };
}
