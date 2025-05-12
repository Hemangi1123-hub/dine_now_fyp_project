import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for the stream of authentication state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// You might add more providers here later, for example:
// - A StateNotifierProvider to manage login/signup form state and actions.
// - A FutureProvider to fetch user profile data from Firestore based on UID.
 