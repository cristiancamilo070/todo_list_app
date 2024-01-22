import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class GetNotesUseCase extends BaseStreamUseCasesNoParams<QuerySnapshot> {
  final FirestoreRepository _firestoreRepository;

  GetNotesUseCase(this._firestoreRepository);

  @override
  Stream<Either<BaseException, QuerySnapshot>> execute() {
    return _firestoreRepository.getNotes();
  }
}
