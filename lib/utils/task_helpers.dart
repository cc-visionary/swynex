import 'package:flutter/material.dart';
import 'package:pig_lifecycle_crm/models/farm_task_model.dart'; // Adjust import path

extension TaskTypeHelpers on TaskType {
  // Provides a user-friendly title for each task type
  String get title {
    switch (this) {
      case TaskType.vaccinate:
        return 'Vaccination';
      case TaskType.clean:
        return 'Pen Cleaning';
      case TaskType.receiveInventory:
        return 'Feed Delivery';
      case TaskType.administerTreatment:
        return 'Administer Treatment';
      case TaskType.observeAnimal:
        return 'Observe Animal';
      case TaskType.weighPigs:
        return 'Weigh Pigs';
      case TaskType.move:
        return 'Move Animal/Batch';
      case TaskType.logFarrowing:
        return 'Log Farrowing';
      case TaskType.checkHeat:
        return 'Check Heat';
      case TaskType.inseminateSow:
        return 'Inseminate Sow';
      case TaskType.checkPregnancy:
        return 'Check Pregnancy';
      case TaskType.performMaintenance:
        return 'Perform Maintenance';
      case TaskType.logFeedUsage:
        return 'Log Feed Usage';
      case TaskType.custom:
        return 'Custom Task';
    }
  }

  // Provides an icon for each task type
  IconData get icon {
    switch (this) {
      case TaskType.vaccinate:
        return Icons.vaccines_rounded;
      case TaskType.administerTreatment:
        return Icons.medication_liquid_rounded;
      case TaskType.observeAnimal:
        return Icons.visibility_rounded;
      case TaskType.weighPigs:
        return Icons.scale_rounded;
      case TaskType.move:
        return Icons.sync_alt_rounded;
      case TaskType.logFarrowing:
        return Icons.child_friendly_rounded;
      case TaskType.checkHeat:
        return Icons.favorite_border_rounded;
      case TaskType.inseminateSow:
        return Icons.biotech_rounded;
      case TaskType.checkPregnancy:
        return Icons.pregnant_woman_rounded;
      case TaskType.clean:
        return Icons.cleaning_services_rounded;
      case TaskType.performMaintenance:
        return Icons.build_rounded;
      case TaskType.logFeedUsage:
        return Icons.ramen_dining_rounded;
      case TaskType.receiveInventory:
        return Icons.local_shipping_rounded;
      case TaskType.custom:
        return Icons.edit_note_rounded;
    }
  }
}
