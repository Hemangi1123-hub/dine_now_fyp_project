import 'package:dine_now/models/user_model.dart';
import 'package:dine_now/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Provider for FirestoreService instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// FutureProvider to fetch UserModel based on UID
// Using .family allows passing the uid argument
final userDataProvider = FutureProvider.family<UserModel?, String>((
  ref,
  uid,
) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUserData(uid);
});

// Optional: Provider for the currently logged-in user's data
// This depends on the auth state and fetches data only when logged in.
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateChangesProvider); // Depend on auth state
  final firestoreService = ref.watch(firestoreServiceProvider);

  final user = authState.asData?.value; // Get the Firebase User if logged in

  if (user != null) {
    return await firestoreService.getUserData(user.uid);
  }
  return null; // Return null if not logged in
});
 