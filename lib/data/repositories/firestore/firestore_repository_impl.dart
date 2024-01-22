// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:todo_list_app/data/providers/firestore/firestore_provider.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';

class FirestoreRepositoryImpl extends FirestoreRepository {
  final FirestoreProvider firestoreProvider;

  FirestoreRepositoryImpl(this.firestoreProvider);

  @override
  Future<Either<BaseException, void>> addNote(
    String title,
    String description,
    DateTime date,
    bool state,
  ) async {
    try {
      await firestoreProvider.addNote(
        title,
        description,
        date,
        state,
      );
      return right(null);
    } catch (e) {
      return left(const BaseException(
        'Error adding note',
        success: false,
        code: null,
        message: '',
      ));
    }
  }

  @override
  Stream<Either<BaseException, QuerySnapshot>> getNotes() {
    try {
      return firestoreProvider.getNotes().map((snapshot) => right(snapshot));
    } catch (e) {
      print('Error getting notes: $e');
      return Stream.value(
        left(
          const BaseException(
            'Error getting notes',
            message: '',
            success: false,
            code: null,
          ),
        ),
      );
    }
  }

  @override
  Future<Either<BaseException, void>> updateNote(
    String noteId,
    String title,
    String description,
    DateTime date,
    bool state,
    bool language,
  ) async {
    try {
      await firestoreProvider.updateNote(
        noteId,
        title,
        description,
        date,
        state,
        language,
      );
      return right(null);
    } catch (e) {
      return left(const BaseException(
        'Error updating note',
        success: false,
        code: null,
        message: '',
      ));
    }
  }

  @override
  Future<Either<BaseException, void>> deleteNote(String noteId) async {
    try {
      await firestoreProvider.deleteNote(noteId);
      return right(null);
    } catch (e) {
      return left(const BaseException(
        'Error deleting note',
        success: false,
        code: null,
        message: '',
      ));
    }
  }
}
