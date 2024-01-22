import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class SaveTokenFirebaseUseCase extends BaseUseCases<void, String> {
  final ProfileRepository _profileRepository;

  SaveTokenFirebaseUseCase(this._profileRepository);

  @override
  Future<Either<BaseException<void>, void>> execute(String params) async {
    return await _profileRepository.saveTokenFirebase(params);
  }
}
