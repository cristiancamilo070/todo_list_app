// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addNote(
    String title,
    String description,
    DateTime date,
    bool state,
    String status, // New field: "To Do", "In Progress", "Done"
  ) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('todo').add({
          'userId': user.uid,
          'title': title,
          'description': description,
          'date': date,
          'state': state,
          'status': status,
          'language': false,
          'titleTranslated': '',
          'descriptionTranslated': ''
        });
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  Stream<QuerySnapshot> getNotes() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('todo')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots();
    } else {
      print('User not logged in.');
      return const Stream.empty();
    }
  }

  Future<void> updateNote(
    String noteId,
    String title,
    String description,
    DateTime date,
    bool state,
    bool language,
    String status,
  ) async {
    try {
      await _firestore.collection('todo').doc(noteId).update({
        'title': title,
        'description': description,
        'date': date,
        'state': state,
        'language': language,
        'status': status,
      });
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('todo').doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
    }
  }
}
