import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class UpdateNoteUseCase extends BaseUseCases<void, UpdateNoteParams> {
  final FirestoreRepository _firestoreRepository;

  UpdateNoteUseCase(this._firestoreRepository);

  @override
  Future<Either<BaseException, void>> execute(UpdateNoteParams params) async {
    return _firestoreRepository.updateNote(
      params.noteId,
      params.title,
      params.description,
      params.date,
      params.state,
      params.language,
    );
  }
}

class UpdateNoteParams {
  final String noteId;
  final String title;
  final String description;
  final DateTime date;
  final bool state;
  final bool language;

  UpdateNoteParams({
    required this.noteId,
    required this.title,
    required this.description,
    required this.date,
    required this.state,
    required this.language,
  });
}
