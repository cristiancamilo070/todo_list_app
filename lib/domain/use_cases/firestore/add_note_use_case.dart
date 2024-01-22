import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class AddNoteUseCase extends BaseUseCases<void, NoteParams> {
  final FirestoreRepository _firestoreRepository;

  AddNoteUseCase(this._firestoreRepository);

  @override
  Future<Either<BaseException, void>> execute(NoteParams params) async {
    return _firestoreRepository.addNote(
      params.title,
      params.description,
      params.date,
      params.state,
    );
  }
}

class NoteParams {
  final String title;
  final String description;
  final DateTime date;
  final bool state;

  NoteParams(
    this.title,
    this.description,
    this.date,
    this.state,
  );
}
