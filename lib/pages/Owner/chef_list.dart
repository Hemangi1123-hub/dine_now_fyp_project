import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ChefListScreen extends StatefulWidget {
  @override
  _ChefListScreenState createState() => _ChefListScreenState();
}

class _ChefListScreenState extends State<ChefListScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Owner')
            .doc(currentUser!.uid)
            .collection('chefs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chefs found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chefDoc = snapshot.data!.docs[index];
              var chefData = chefDoc.data() as Map<String, dynamic>;
              String email = chefData['email'] ?? 'N/A';
              String uid = chefData['chef'] ?? 'N/A';
              return ListTile(
                title: Text(email),
                subtitle: Text('UID: $uid'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // Handle accept action
                        _handleAction(context, chefDoc.id, true);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // Handle reject action
                        _handleAction(context, chefDoc.id, false);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleAction(
      BuildContext context, String chefDocId, bool isAccept) async {
    String ownerUid = currentUser!.uid;
    try {
      if (isAccept) {
        // Update the chef's status in the 'Chef' collection
        await FirebaseFirestore.instance
            .collection('Chef')
            .doc(chefDocId)
            .update({
          'hotel': ownerUid,
          'status': 'accepted',
        });
      } else {
        // Update the chef's status in the 'Chef' collection
        await FirebaseFirestore.instance
            .collection('Chef')
            .doc(chefDocId)
            .update({'status': 'rejected'});
      }
      // Delete the chef's record from the 'Owner/{ownerUid}/chefs' subcollection
      await FirebaseFirestore.instance
          .collection('Owner')
          .doc(ownerUid)
          .collection('chefs')
          .doc(chefDocId)
          .delete();
      print(
          '${isAccept ? "Accepted" : "Rejected"} and removed chef with ID: $chefDocId');
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      print('Error ${isAccept ? "accepting" : "rejecting"} chef: $e');
      return;
    }
  }
}