import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class SignupPasswordUseCase extends BaseUseCases<String?, LoginParams> {
  final ProfileRepository _profileRepository;

  SignupPasswordUseCase(this._profileRepository);

  @override
  Future<Either<BaseException, String?>> execute(LoginParams params) async {
    return _profileRepository.signUp(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams(this.email, this.password);
}
