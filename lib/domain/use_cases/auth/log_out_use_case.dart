import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class LogOutUseCase extends BaseUseCasesNoParams<bool> {
  final ProfileRepository _profileRepository;

  LogOutUseCase(this._profileRepository);

  @override
  Future<Either<BaseException, bool>> execute() async {
    return await _profileRepository.signOut();
  }
}
