import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';

abstract class FirestoreRepository {
  Future<Either<BaseException, void>> addNote(
    String title,
    String description,
    DateTime date,
    bool state,
  );
  Stream<Either<BaseException, QuerySnapshot>> getNotes();

  Future<Either<BaseException, void>> updateNote(
    String noteId,
    String title,
    String description,
    DateTime date,
    bool state,
    bool language,
  );
  Future<Either<BaseException, void>> deleteNote(String noteId);
}
