import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class DeleteNoteUseCase extends BaseUseCases<void, String> {
  final FirestoreRepository _firestoreRepository;

  DeleteNoteUseCase(this._firestoreRepository);

  @override
  Future<Either<BaseException, void>> execute(String params) async {
    return _firestoreRepository.deleteNote(params);
  }
}
