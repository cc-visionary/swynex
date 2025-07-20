import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart'; // Assuming you have an index file for all models

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Generic Helper Methods ---
  Stream<List<T>> _getCollectionStream<T>({
    required String path,
    required T Function(DocumentSnapshot<Map<String, dynamic>> doc)
    fromSnapshot,
  }) {
    return _db
        .collection(path)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromSnapshot(doc)).toList(),
        );
  }

  Future<void> _addDocument({
    required String path,
    required Map<String, dynamic> data,
  }) {
    return _db.collection(path).add(data);
  }

  Future<void> _updateDocument({
    required String path,
    required Map<String, dynamic> data,
  }) {
    return _db.doc(path).update(data);
  }

  Future<void> _deleteDocument({required String path}) {
    return _db.doc(path).delete();
  }

  // --- Sales Records ---
  Stream<List<SaleRecord>> getSales() => _getCollectionStream(
    path: 'sales_records',
    fromSnapshot: SaleRecord.fromSnapshot,
  );
  Future<void> addSale(SaleRecord sale) =>
      _addDocument(path: 'sales_records', data: sale.toJson());
  Future<void> updateSale(SaleRecord sale) =>
      _updateDocument(path: 'sales_records/${sale.id}', data: sale.toJson());
  Future<void> deleteSale(String id) =>
      _deleteDocument(path: 'sales_records/$id');

  // --- Cost Records ---
  Stream<List<CostRecord>> getCosts() => _getCollectionStream(
    path: 'cost_records',
    fromSnapshot: CostRecord.fromSnapshot,
  );
  Future<void> addCost(CostRecord cost) =>
      _addDocument(path: 'cost_records', data: cost.toJson());
  Future<void> updateCost(CostRecord cost) =>
      _updateDocument(path: 'cost_records/${cost.id}', data: cost.toJson());
  Future<void> deleteCost(String id) =>
      _deleteDocument(path: 'cost_records/$id');

  // --- Inventory Items ---
  Stream<List<InventoryItem>> getInventoryItems() => _getCollectionStream(
    path: 'inventory_items',
    fromSnapshot: InventoryItem.fromSnapshot,
  );
  Future<void> addInventoryItem(InventoryItem item) =>
      _addDocument(path: 'inventory_items', data: item.toJson());
  Future<void> updateInventoryItem(InventoryItem item) =>
      _updateDocument(path: 'inventory_items/${item.id}', data: item.toJson());
  Future<void> deleteInventoryItem(String id) =>
      _deleteDocument(path: 'inventory_items/$id');

  // --- Weight Records ---
  Stream<List<WeightRecord>> getWeightRecordsForPig(String pigId) {
    return _db
        .collection('weight_records')
        .where('pig_id', isEqualTo: pigId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WeightRecord.fromSnapshot(doc))
                  .toList(),
        );
  }

  Future<void> addWeightRecord(WeightRecord record) =>
      _addDocument(path: 'weight_records', data: record.toJson());

  // --- Health Logs ---
  Stream<List<HealthLog>> getHealthLogsForPig(String pigId) {
    return _db
        .collection('health_logs')
        .where('pig_id', isEqualTo: pigId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => HealthLog.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> addHealthLog(HealthLog log) =>
      _addDocument(path: 'health_logs', data: log.toJson());

  // --- Farrowing Records ---
  Stream<List<FarrowingRecord>> getFarrowingRecordsForSow(String sowId) {
    return _db
        .collection('breeding_cycles')
        .where('sow_id', isEqualTo: sowId)
        .snapshots()
        .asyncMap((breedingCycleSnap) async {
          List<FarrowingRecord> records = [];
          for (var cycleDoc in breedingCycleSnap.docs) {
            final farrowingSnap =
                await _db
                    .collection('farrowing_records')
                    .where('cycle_id', isEqualTo: cycleDoc.id)
                    .get();
            records.addAll(
              farrowingSnap.docs.map(
                (doc) => FarrowingRecord.fromSnapshot(doc),
              ),
            );
          }
          return records;
        });
  }

  Future<void> addFarrowingRecord(FarrowingRecord record) =>
      _addDocument(path: 'farrowing_records', data: record.toJson());

  // --- Breeding Cycles ---
  Stream<List<BreedingCycle>> getBreedingCyclesForSow(String sowId) {
    return _db
        .collection('breeding_cycles')
        .where('sow_id', isEqualTo: sowId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BreedingCycle.fromSnapshot(doc))
                  .toList(),
        );
  }

  Future<void> addBreedingCycle(BreedingCycle cycle) =>
      _addDocument(path: 'breeding_cycles', data: cycle.toJson());
  Future<void> updateBreedingCycle(BreedingCycle cycle) => _updateDocument(
    path: 'breeding_cycles/${cycle.id}',
    data: cycle.toJson(),
  );

  // --- Pig Batches ---
  Stream<List<PigBatch>> getBatchesStream(String farmId) {
    return _db
        .collection('pig_batches')
        // .where('farmId', isEqualTo: farmId) // For future use
        .orderBy('creationDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PigBatch.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> addPigBatch(PigBatch batch) =>
      _addDocument(path: 'pig_batches', data: batch.toJson());

  Future<void> updatePigBatch(PigBatch batch) =>
      _updateDocument(path: 'pig_batches/${batch.id}', data: batch.toJson());

  // --- Pigs ---
  Stream<List<Pig>> getPigsStream(String farmId) {
    return _db
        .collection('pigs')
        // .where('farmId', isEqualTo: farmId) // When you implement multi-farm
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Pig.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> addPigsAndCreateBatch({
    required PigBatch batchData,
    required List<Pig> pigsInBatch,
    String? farmId,
  }) async {
    final batch = _db.batch();

    // 1. Create a document reference for the new batch to get its ID
    final batchRef = _db.collection('pig_batches').doc();

    // 2. Add the batch creation to the batch operation
    final newBatch = PigBatch(
      id: batchRef.id,
      batchName: batchData.batchName,
      creationDate: batchData.creationDate,
      notes: batchData.notes,
    );
    batch.set(batchRef, newBatch.toJson());

    // 3. Loop through pigs, assign the new batchId, and add them to the batch operation
    for (final pig in pigsInBatch) {
      final pigRef = _db.collection('pigs').doc(); // Auto-generate pig ID
      final newPig = Pig(
        id: pigRef.id,
        farmTagId: pig.farmTagId,
        batchId: batchRef.id, // <-- Assign the new batch's ID
        gender: pig.gender,
        status: pig.status,
        birthDate: pig.birthDate,
        damId: pig.damId,
        sireId: pig.sireId,
        currentPenId: pig.currentPenId,
        // farmId: farmId, // For future multi-farm support
      );
      batch.set(pigRef, newPig.toJson());
    }

    // 4. Commit all operations at once.
    return batch.commit();
  }

  Future<void> addPig(Pig pig) {
    // 1. Create a reference to a new document with an auto-generated ID.
    final docRef = _db.collection('pigs').doc();

    // 2. Create a new Pig instance that includes the new ID.
    //    This ensures the document in Firestore contains its own ID.
    final pigWithId = Pig(
      id: docRef.id,
      farmTagId: pig.farmTagId,
      gender: pig.gender,
      breed: pig.breed,
      birthDate: pig.birthDate,
      damId: pig.damId,
      sireId: pig.sireId,
      batchId: pig.batchId,
      currentPenId: pig.currentPenId,
      status: pig.status,
      cullingReason: pig.cullingReason,
    );

    // 3. Set the data for the new document.
    return docRef.set(pigWithId.toJson());
  }

  Future<void> updatePig(Pig pig) {
    return _db.collection('pigs').doc(pig.id).update(pig.toJson());
  }

  Future<void> deletePigs(List<String> pigIds) {
    final batch = _db.batch();
    for (final id in pigIds) {
      batch.delete(_db.collection('pigs').doc(id));
    }
    return batch.commit();
  }

  Future<void> deleteBatchAndPigs(String batchId) async {
    // 1. Find all the pigs that belong to this batch.
    final pigsSnapshot =
        await _db.collection('pigs').where('batchId', isEqualTo: batchId).get();

    final batch = _db.batch();

    // 2. Mark each pig in the batch for deletion.
    for (final doc in pigsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Mark the main batch document itself for deletion.
    final batchRef = _db.collection('pig_batches').doc(batchId);
    batch.delete(batchRef);

    // 4. Commit all deletions in a single, atomic operation.
    return batch.commit();
  }

  // --- Users ---
  Future<void> createUser(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    // Step 1: Create the user in Firebase Authentication
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Step 2: Create the user document in Firestore with the same UID
    if (userCredential.user != null) {
      final newUser = AppUser(
        id: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        role: role,
      );
      await _db.collection('users').doc(newUser.id).set(newUser.toJson());
    }
  }

  // Also add a method to get all users
  Stream<List<AppUser>> getUsersStream() {
    return _db
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> updateUser(String userId, String fullName, String role) {
    return _db.collection('users').doc(userId).update({
      'fullName': fullName,
      'role': role,
    });
  }

  Future<void> deleteUser(String userId) {
    // NOTE: Deleting a user from FirebaseAuth is a secure operation that requires
    // the user to have recently signed in. For now, this will only delete
    // the user's data from the Firestore database, not their login.
    return _db.collection('users').doc(userId).delete();
  }

  //--- Farm Location ---
  Future<void> addMultipleLocations(List<FarmLocation> locations) {
    final batch = _db.batch();
    for (final location in locations) {
      final docRef =
          _db.collection('farm_locations').doc(); // Create new doc with auto-ID
      // Create a new location object with the generated ID to save
      final newLocation = FarmLocation(
        id: docRef.id,
        name: location.name,
        type: location.type,
        parentId: location.parentId,
      );
      batch.set(docRef, newLocation.toJson());
    }
    return batch.commit();
  }

  Stream<List<FarmLocation>> getLocationsStream() {
    return _db
        .collection('farm_locations')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FarmLocation.fromSnapshot(doc))
                  .toList(),
        );
  }

  Future<void> updateLocationName(String locationId, String newName) {
    return _db.collection('farm_locations').doc(locationId).update({
      'name': newName,
    });
  }

  // TODO: Remove all child locations before deleting a location
  Future<void> deleteLocation(String locationId) {
    return _db.collection('farm_locations').doc(locationId).delete();
  }

  //--- Task Methods ---
  Stream<List<FarmTask>> getTasksStream() {
    return _db
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => FarmTask.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> addTask(Map<String, dynamic> taskData) {
    return _db.collection('tasks').add(taskData);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) {
    return _db.collection('tasks').doc(taskId).update(taskData);
  }

  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }
}
