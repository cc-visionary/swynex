import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/core/services/firestore_service.dart';
import 'package:pig_lifecycle_crm/features/financials/data/models/cost_record_model.dart';

class CostRecordsViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<CostRecord>> get costRecordsStream =>
      _firestoreService.getCostRecordsStream("farm_id_placeholder");

  Future<void> addCostRecord(CostRecord costRecord) async {
    await _firestoreService.addCostRecord(costRecord);
  }
}
