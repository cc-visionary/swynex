import 'package:flutter/foundation.dart';
import 'package:pig_lifecycle_crm/core/services/firestore_service.dart';
import 'package:pig_lifecycle_crm/features/settings/data/models/user_model.dart';

class UserManagementViewModel with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<AppUser>> get usersStream => _firestoreService.getUsersStream();

  Future<String?> addUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      await _firestoreService.createUser(email, password, fullName, role);
      return null; // Indicates success
    } catch (e) {
      // Return the error message to display on the UI
      return e.toString();
    }
  }

  Future<String?> updateUser(AppUser user) async {
    try {
      await _firestoreService.updateUser(user.id, user.fullName, user.role);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteUser(userId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
