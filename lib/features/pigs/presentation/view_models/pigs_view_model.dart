import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pig_lifecycle_crm/core/services/firestore_service.dart';
import 'package:pig_lifecycle_crm/features/pigs/data/models/pig_batch_model.dart';
import 'package:pig_lifecycle_crm/features/pigs/data/models/pig_model.dart';
import 'package:pig_lifecycle_crm/features/settings/data/models/farm_location_model.dart';
import 'package:rxdart/rxdart.dart';

class PenAssignment {
  final String penId;
  final int quantity;
  PenAssignment({required this.penId, required this.quantity});
}

enum PigViewMode { batch, list }

class PigsViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // --- 1. Subjects: The single source of truth for raw data from Firestore ---
  final _pigsSubject = BehaviorSubject<List<Pig>>.seeded([]);
  final _batchesSubject = BehaviorSubject<List<PigBatch>>.seeded([]);
  final _locationsSubject = BehaviorSubject<List<FarmLocation>>.seeded([]);
  StreamSubscription? _dataSubscription;

  // --- 2. State: Private variables to hold the current UI state ---
  final Set<String> _selectedPigIds = {};
  PigViewMode _viewMode = PigViewMode.batch;
  Set<String> _selectedBuildingIds = {};
  Set<String> _selectedRoomIds = {};
  Set<String> _selectedPenIds = {};
  Set<String> _selectedGenders = {};
  Set<String> _selectedBreeds = {};

  // --- 3. Public Getters: The UI builds from these ---

  List<PigBatch> get allBatches => _batchesSubject.value;

  // Filtered lists are calculated on-the-fly from the latest data
  List<PigBatch> get filteredBatches {
    // First, get the set of all batch IDs that are present on the currently filtered pigs.
    final visibleBatchIds = filteredPigs.map((p) => p.batchId).toSet();

    // Then, return only the batch objects that match these IDs.
    return allBatches
        .where((batch) => visibleBatchIds.contains(batch.id))
        .toList();
  }

  List<Pig> get filteredPigs {
    Iterable<Pig> pigs = _pigsSubject.value;

    if (_selectedBuildingIds.isNotEmpty ||
        _selectedRoomIds.isNotEmpty ||
        _selectedPenIds.isNotEmpty) {
      // Get locations from the subject's value
      final roomIdsInSelectedBuildings =
          _locationsSubject.value
              .where(
                (l) =>
                    l.type == 'room' &&
                    _selectedBuildingIds.contains(l.parentId),
              )
              .map((r) => r.id)
              .toSet();

      final allSelectedRoomIds = {
        ..._selectedRoomIds,
        ...roomIdsInSelectedBuildings,
      };

      // Get locations from the subject's value
      final penIdsInSelectedRooms =
          _locationsSubject.value
              .where(
                (l) =>
                    l.type == 'pen' && allSelectedRoomIds.contains(l.parentId),
              )
              .map((p) => p.id)
              .toSet();

      final allSelectedPenIds = {..._selectedPenIds, ...penIdsInSelectedRooms};

      if (allSelectedPenIds.isNotEmpty) {
        pigs = pigs.where((p) => allSelectedPenIds.contains(p.currentPenId));
      }
    }

    if (_selectedGenders.isNotEmpty) {
      pigs = pigs.where((p) => _selectedGenders.contains(p.gender));
    }
    if (_selectedBreeds.isNotEmpty) {
      pigs = pigs.where((p) => _selectedBreeds.contains(p.breed));
    }

    return pigs.toList();
  }

  // Getters for populating filter dropdowns
  List<FarmLocation> get buildings =>
      _locationsSubject.value.where((l) => l.type == 'building').toList();
  List<FarmLocation> getRoomsInBuilding(Set<String> buildingIds) =>
      _locationsSubject.value
          .where((l) => l.type == 'room' && buildingIds.contains(l.parentId))
          .toList();
  List<FarmLocation> getPensInRoom(Set<String> roomIds) =>
      _locationsSubject.value
          .where((l) => l.type == 'pen' && roomIds.contains(l.parentId))
          .toList();
  List<FarmLocation> get pens =>
      _locationsSubject.value.where((l) => l.type == 'pen').toList();

  // Getters for synchronous access
  List<Pig> get farrowingSows {
    final allPigs = _pigsSubject.valueOrNull ?? [];
    // A sow is a female with a status of 'Sow' or 'Gilt'
    return allPigs.where((p) {
      return p.gender == 'Female' && (p.status == 'Sow' || p.status == 'Gilt');
    }).toList();
  }

  List<Pig> get boars {
    final allPigs = _pigsSubject.valueOrNull ?? [];
    return allPigs
        .where((p) => p.gender == 'Male' && p.status == 'Boar')
        .toList();
  }

  Set<String> get selectedPigIds => _selectedPigIds;
  PigViewMode get viewMode => _viewMode;

  Map<String, Set<String>> get appliedFilters => {
    'buildingIds': _selectedBuildingIds,
    'roomIds': _selectedRoomIds,
    'penIds': _selectedPenIds,
    'genders': _selectedGenders,
    'breeds': _selectedBreeds,
  };

  // --- 4. Constructor: Initialize the data flow ---
  PigsViewModel(String farmId) {
    _firestoreService.getPigsStream(farmId).pipe(_pigsSubject);
    _firestoreService.getBatchesStream(farmId).pipe(_batchesSubject);
    _firestoreService.getLocationsStream().pipe(_locationsSubject);

    // Listen to the combined stream of all subjects
    _dataSubscription = Rx.combineLatest3(
      _pigsSubject,
      _batchesSubject,
      _locationsSubject,
      (pigs, batches, locations) => null, // We just need a signal
    ).listen((_) {
      // When any of the source streams emit, this will fire.
      notifyListeners();
    });
  }

  // --- 5. Dispose: Crucial for preventing memory leaks ---
  @override
  void dispose() {
    _dataSubscription?.cancel();
    _pigsSubject.close();
    _batchesSubject.close();
    _locationsSubject.close();
    super.dispose();
  }

  // --- 6. Public Methods: UI calls these to change state ---

  void toggleViewMode() {
    _viewMode =
        _viewMode == PigViewMode.batch ? PigViewMode.list : PigViewMode.batch;
    clearSelection();
    notifyListeners();
  }

  void applyFilters({
    Set<String>? buildingIds,
    Set<String>? roomIds,
    Set<String>? penIds,
    Set<String>? genders,
    Set<String>? breeds,
  }) {
    _selectedBuildingIds = buildingIds ?? _selectedBuildingIds;
    _selectedRoomIds = roomIds ?? _selectedRoomIds;
    _selectedPenIds = penIds ?? _selectedPenIds;
    _selectedGenders = genders ?? _selectedGenders;
    _selectedBreeds = breeds ?? _selectedBreeds;
    clearSelection();
    notifyListeners();
  }

  void clearFilters() {
    _selectedBuildingIds = {};
    _selectedRoomIds = {};
    _selectedPenIds = {};
    _selectedGenders = {};
    _selectedBreeds = {};
    clearSelection();
    notifyListeners();
  }

  bool isPigSelected(String pigId) => _selectedPigIds.contains(pigId);

  void togglePigSelection(String pigId) {
    isPigSelected(pigId)
        ? _selectedPigIds.remove(pigId)
        : _selectedPigIds.add(pigId);
    notifyListeners();
  }

  void toggleBatchSelection(List<Pig> pigsInBatch) {
    final batchIds = pigsInBatch.map((p) => p.id!).toSet();
    final areAllSelected = batchIds.every((id) => _selectedPigIds.contains(id));
    areAllSelected
        ? _selectedPigIds.removeAll(batchIds)
        : _selectedPigIds.addAll(batchIds);
    notifyListeners();
  }

  void clearSelection() {
    _selectedPigIds.clear();
    notifyListeners();
  }

  Future<void> addLitter({
    required int numberOfPiglets,
    required String damId,
    String? sireId,
    required DateTime birthDate,
  }) async {
    final motherSow = (_pigsSubject.valueOrNull ?? []).firstWhere(
      (p) => p.id == damId,
      orElse: () => throw Exception('Mother sow not found'),
    );
    final timestamp = DateFormat('yyMMdd-HHmmss').format(birthDate);
    final newBatchData = PigBatch(
      batchName: 'Litter from ${motherSow.farmTagId} - $timestamp',
      creationDate: birthDate,
      notes: 'Farrowed from sow ${motherSow.farmTagId}.',
    );
    final List<Pig> newLitter = [];
    for (int i = 1; i <= numberOfPiglets; i++) {
      final tagId =
          '${motherSow.farmTagId}-${timestamp}-${i.toString().padLeft(2, '0')}';
      newLitter.add(
        Pig(
          farmTagId: tagId,
          gender: 'Weaner',
          status: 'Suckling',
          birthDate: birthDate,
          damId: damId,
          sireId: sireId,
          currentPenId: motherSow.currentPenId,
        ),
      );
    }
    await _firestoreService.addPigsAndCreateBatch(
      batchData: newBatchData,
      pigsInBatch: newLitter,
      totalCost: 0,
    );
  }

  Future<void> addPurchaseBatch({
    required List<PenAssignment> assignments,
    required double totalCost,
    required String gender,
    required String status,
    required DateTime purchaseDate,
    String? breed,
  }) async {
    // Calculate total number of pigs from the assignments
    final totalPigs = assignments.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final timestamp = DateFormat('yyMMdd-HHmmss').format(purchaseDate);
    final newBatchData = PigBatch(
      batchName: 'Purchase - $timestamp',
      creationDate: purchaseDate,
      notes: '$totalPigs pigs purchased.',
    );
    final List<Pig> newPurchase = [];
    int pigCounter = 0; // To ensure unique tag IDs across all assignments

    // --- Loop through each assignment to create pigs ---
    for (final assignment in assignments) {
      for (int i = 1; i <= assignment.quantity; i++) {
        pigCounter++;
        final tagId =
            'PUR-${DateFormat('yyMMdd').format(purchaseDate)}-${pigCounter.toString().padLeft(3, '0')}';
        newPurchase.add(
          Pig(
            farmTagId: tagId,
            gender: gender,
            status: status,
            breed: breed,
            birthDate: purchaseDate,
            currentPenId: assignment.penId, // <-- Assign to the correct pen
          ),
        );
      }
    }
    await _firestoreService.addPigsAndCreateBatch(
      batchData: newBatchData,
      pigsInBatch: newPurchase,
      totalCost: totalCost,
    );
  }

  List<Pig> get allPigs => _pigsSubject.value;
  // Future<void> addPig(Pig pig) async {
  //   final dateForName = DateFormat('yyyy-MM-dd').format(pig.birthDate);
  //   final newBatchData = PigBatch(
  //     batchName: 'Single Pig - ${pig.farmTagId} - $dateForName',
  //     creationDate: pig.birthDate,
  //     notes: 'Added as a single pig.',
  //   );
  //   await _firestoreService.addPigsAndCreateBatch(
  //     batchData: newBatchData,
  //     pigsInBatch: [pig],
  //   );
  // }

  Future<void> updatePig(Pig pig) => _firestoreService.updatePig(pig);
  Future<void> deleteSelectedPigs() async {
    await _firestoreService.deletePigs(_selectedPigIds.toList());
    clearSelection();
  }

  Future<void> deleteBatchAndPigs(PigBatch batch) =>
      _firestoreService.deleteBatchAndPigs(batch.id!);
}
