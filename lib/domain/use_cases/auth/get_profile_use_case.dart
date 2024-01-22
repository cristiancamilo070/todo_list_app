import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/models/user_model.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class GetProfileUseCase extends BaseUseCasesNoParams<UserModel?> {
  final ProfileRepository _profileRepository;

  GetProfileUseCase(this._profileRepository);

  @override
  Future<Either<BaseException, UserModel?>> execute() async {
    return await _profileRepository.getProfileData();
  }
}
