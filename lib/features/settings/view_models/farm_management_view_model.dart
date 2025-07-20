import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/models/models.dart';
import 'package:pig_lifecycle_crm/services/firestore_service.dart';

class FarmManagementViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<FarmLocation> _allLocations = [];
  StreamSubscription? _locationsSubscription;

  FarmManagementViewModel() {
    // Listen to the stream from Firestore to get real-time updates.
    _locationsSubscription = _firestoreService.getLocationsStream().listen((
      locations,
    ) {
      _allLocations = locations;
      // Tell the UI to rebuild because our local list has changed.
      notifyListeners();
    });
  }

  // Getters to create the hierarchy
  List<FarmLocation> get buildings =>
      _allLocations.where((loc) => loc.type == 'building').toList();

  List<FarmLocation> getRoomsInBuilding(String buildingId) =>
      _allLocations
          .where((loc) => loc.type == 'room' && loc.parentId == buildingId)
          .toList();

  List<FarmLocation> getPensInRoom(String roomId) =>
      _allLocations
          .where((loc) => loc.type == 'pen' && loc.parentId == roomId)
          .toList();

  Future<void> addLocations({
    required List<String> names,
    required String type,
    String? parentId,
  }) async {
    final locations =
        names
            .map(
              (name) => FarmLocation(
                id: '',
                name: name,
                type: type,
                parentId: parentId,
              ),
            )
            .toList();
    await _firestoreService.addMultipleLocations(locations);
  }

  Future<void> updateLocationName(String locationId, String newName) async {
    await _firestoreService.updateLocationName(locationId, newName);
  }

  Future<void> deleteLocation(String locationId) async {
    await _firestoreService.deleteLocation(locationId);
  }

  @override
  void dispose() {
    _locationsSubscription?.cancel();
    super.dispose();
  }
}
