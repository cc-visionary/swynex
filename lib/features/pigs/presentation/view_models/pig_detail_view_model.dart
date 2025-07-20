import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/core/services/firestore_service.dart';
import 'package:pig_lifecycle_crm/features/health/data/models/health_log_model.dart';
import 'package:pig_lifecycle_crm/features/pigs/data/models/breeding_cycle_model.dart';
import 'package:pig_lifecycle_crm/features/pigs/data/models/pig_model.dart';
import 'package:rxdart/rxdart.dart';

class PigDetailViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final String pigId;

  // --- 1. Subjects: To cache and broadcast the data for this pig ---
  final _pigSubject = BehaviorSubject<Pig?>();
  final _healthLogsSubject = BehaviorSubject<List<HealthLog>>.seeded([]);
  final _breedingCyclesSubject = BehaviorSubject<List<BreedingCycle>>.seeded(
    [],
  );

  // --- 2. Public Getters: The UI will listen to these streams ---
  Stream<Pig?> get pigStream => _pigSubject.stream;
  Stream<List<HealthLog>> get healthLogsStream => _healthLogsSubject.stream;
  Stream<List<BreedingCycle>> get breedingCyclesStream =>
      _breedingCyclesSubject.stream;

  // --- 3. Constructor: Initializes the data flow ---
  PigDetailViewModel({required this.pigId}) {
    // Pipe the data from Firestore directly into the subjects
    _firestoreService.getPigStream(pigId).pipe(_pigSubject);
    _firestoreService.getHealthLogsForPig(pigId).pipe(_healthLogsSubject);

    // Assuming only sows have breeding cycles
    // In a real app, you might check the pig's gender before fetching
    _firestoreService
        .getBreedingCyclesForSow(pigId)
        .pipe(_breedingCyclesSubject);
  }

  // --- 4. Dispose: Crucial for preventing memory leaks ---
  @override
  void dispose() {
    _pigSubject.close();
    _healthLogsSubject.close();
    _breedingCyclesSubject.close();
    super.dispose();
  }

  // You can add methods for editing/deleting this specific pig later
}
