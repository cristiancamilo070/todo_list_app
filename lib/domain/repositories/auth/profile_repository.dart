import 'package:dartz/dartz.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/models/user_model.dart';

abstract class ProfileRepository {
  Future<String?> obtainToken(
    String email,
    String password,
  );
  Future<Either<BaseException, UserModel?>> getProfileData();
  Future<Either<BaseException, String?>> signUp(String email, String password);
  Future<Either<BaseException, String?>> signIn(String email, String password);
  Future<Either<BaseException, void>> saveTokenFirebase(String token);
  Future<Either<BaseException, bool>> signOut();
}
