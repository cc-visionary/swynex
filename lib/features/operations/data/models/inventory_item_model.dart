// lib/models/inventory_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String? id;
  final String itemName;
  final String itemType; // 'medicine', 'vaccine', 'feed'
  final double quantityOnHand;
  final String unit; // 'ml', 'kg', 'sacks'
  final double? reorderLevel;

  InventoryItem({
    this.id,
    required this.itemName,
    required this.itemType,
    required this.quantityOnHand,
    required this.unit,
    this.reorderLevel,
  });

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'item_type': itemType,
    'quantity_on_hand': quantityOnHand,
    'unit': unit,
    'reorder_level': reorderLevel,
  };

  factory InventoryItem.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return InventoryItem(
      id: doc.id,
      itemName: data['item_name'],
      itemType: data['item_type'],
      quantityOnHand: data['quantity_on_hand'],
      unit: data['unit'],
      reorderLevel: data['reorder_level'],
    );
  }
}
