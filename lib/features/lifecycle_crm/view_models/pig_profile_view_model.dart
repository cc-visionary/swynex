
import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/models/pig_model.dart';
import 'package:pig_lifecycle_crm/services/firestore_service.dart';

class PigProfileViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final String pigId;

  Pig? _pig;
  Pig? get pig => _pig;

  PigProfileViewModel(this.pigId) {
    _fetchPig();
  }

  Future<void> _fetchPig() async {
    _pig = await _firestoreService.getPig(pigId);
    notifyListeners();
  }
}
