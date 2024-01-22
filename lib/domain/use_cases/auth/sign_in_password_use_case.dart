import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_up_password_use_case.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class SignInPasswordUseCase extends BaseUseCases<String?, LoginParams> {
  final ProfileRepository _profileRepository;

  SignInPasswordUseCase(this._profileRepository);

  @override
  Future<Either<BaseException, String?>> execute(LoginParams params) async {
    return _profileRepository.signIn(params.email, params.password);
  }
}
