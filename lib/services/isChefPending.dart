import 'package:cloud_firestore/cloud_firestore.dart';

/// Function to check if a hotel UID exists in the user's booking collection.
/// @param userId - The ID of the user.
/// @param hotelUid - The UID of the hotel to check.
/// @returns Future<bool> - Returns true if the hotel UID exists, otherwise false.
class CheckRequest {
  Future<bool> isChefPending(String userId) async {
    try {
      // Reference to the Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the user's booking document in the 'booking' collection

      final DocumentReference chefRequestRef =
          firestore.collection('Chef').doc(userId);
      DocumentSnapshot chefRequestSnapshot = await chefRequestRef.get();

      // Fetch the query snapshot
      if (chefRequestSnapshot.data() != null) {
        print(chefRequestSnapshot.data());
        print(chefRequestSnapshot['status']);
        if (chefRequestSnapshot['status'] == 'accepted') {
          print('accepted');
          return true; // Return true if a match is found
        }
      } else {
        print('No requests found');
      }

      // Return false if no matching document is found
      return false;
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error checking if reqest is accepted: $e');
      return false;
    }
  }
}
