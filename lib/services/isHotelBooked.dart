import 'package:cloud_firestore/cloud_firestore.dart';

/// Function to check if a hotel UID exists in the user's booking collection.
/// @param userId - The ID of the user.
/// @param hotelUid - The UID of the hotel to check.
/// @returns Future<bool> - Returns true if the hotel UID exists, otherwise false.
class CheckBooking {
  Future<bool> isHotelBooked(String userId, String hotelUid) async {
    try {
      // Reference to the Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the user's booking document in the 'booking' collection
      final CollectionReference userBookingRef =
          firestore.collection('User').doc(userId).collection('Booking');

      // Fetch the query snapshot
      QuerySnapshot querySnapshot = await userBookingRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Loop through each document to find the matching hotelUid and 'today' date
        for (var doc in querySnapshot.docs) {
          print(doc.data());
          print(doc['user'] + ' <-> ' + hotelUid);
          if (doc['user'] == hotelUid && doc['date'] == 'today') {
            print('matched');
            return true; // Return true if a match is found
          }
        }
      } else {
        print('No bookings found for today');
      }

      // Return false if no matching document is found
      return false;
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error checking if hotel is booked: $e');
      return false;
    }
  }
}
