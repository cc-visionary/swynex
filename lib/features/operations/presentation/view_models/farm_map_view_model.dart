import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/features/pigs/data/models/pig_model.dart';
import 'package:pig_lifecycle_crm/features/settings/data/models/farm_location_model.dart';
import 'package:pig_lifecycle_crm/core/services/firestore_service.dart';
import 'package:pig_lifecycle_crm/features/tasks/data/models/farm_task_model.dart';

class FarmMapViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<FarmLocation> _locations = [];
  List<Pig> _pigs = [];
  List<FarmTask> _tasks = [];

  List<FarmLocation> get locations => _locations;
  List<Pig> get pigs => _pigs;
  List<FarmTask> get tasks => _tasks;

  FarmMapViewModel() {
    _fetchData();
  }

  void _fetchData() {
    _firestoreService.getLocationsStream().listen((locations) {
      _locations = locations;
      notifyListeners();
    });

    _firestoreService.getPigsStream('farm_id_placeholder').listen((pigs) {
      _pigs = pigs;
      notifyListeners();
    });

    _firestoreService.getTasksStream().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  int getAggregatedPigCountForLocation(FarmLocation location) {
    Set<String> relevantPenIds = {};

    if (location.type == 'building') {
      // 1. Find all rooms in the building
      final roomIds =
          _locations
              .where((room) => room.parentId == location.id)
              .map((room) => room.id)
              .toSet();

      // 2. Find all pens in those rooms
      relevantPenIds =
          _locations
              .where((pen) => roomIds.contains(pen.parentId))
              .map((pen) => pen.id)
              .toSet();
    } else if (location.type == 'room') {
      // Find all pens in the room
      relevantPenIds =
          _locations
              .where((pen) => pen.parentId == location.id)
              .map((pen) => pen.id)
              .toSet();
    } else {
      // Assumes 'Pen'
      relevantPenIds = {location.id};
    }

    if (relevantPenIds.isEmpty) return 0;

    // 3. Count pigs that are in any of the relevant pens
    return _pigs
        .where((pig) => relevantPenIds.contains(pig.currentPenId))
        .length;
  }

  int getAggregatedTaskCountForLocation(FarmLocation location) {
    return 0; // _tasks.where((task) => task.locationId == locationId).length;
  }
}
