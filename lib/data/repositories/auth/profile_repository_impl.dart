import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:todo_list_app/data/providers/auth/firebase_auth_provider.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/models/user_model.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final FirebaseAuthProvider firebaseAuthProvider;

  ProfileRepositoryImpl(this.firebaseAuthProvider);

  @override
  Future<String?> obtainToken(String email, String password) async {
    // Implement Firebase sign-in with email and password
    try {
      await firebaseAuthProvider.signInWithEmailAndPassword(email, password);
      return await firebaseAuthProvider.getAccessToken();
    } catch (e) {
      return null; // Handle errors and return null or appropriate value
    }
  }

  @override
  Future<Either<BaseException, void>> saveTokenFirebase(String token) async {
    try {
      return right(null); // Return right if successful
    } catch (e) {
      return left(const BaseException('Error saving token',
          success: false,
          code: null,
          message: '')); // Return left if an error occurs
    }
  }

  @override
  Future<Either<BaseException, String?>> signUp(
      String email, String password) async {
    // Implement Firebase sign-up with email and password
    try {
      await firebaseAuthProvider.signUpWithEmailAndPassword(email, password);
      return right(await firebaseAuthProvider.getAccessToken());
    } catch (e) {
      return left(const BaseException('Error sign up ',
          success: false,
          code: null,
          message: '')); // Return left if an error occurs
    }
  }

  @override
  Future<Either<BaseException, String?>> signIn(
      String email, String password) async {
    // Implement Firebase sign-in with email and password
    try {
      await firebaseAuthProvider.signInWithEmailAndPassword(email, password);
      return right(await firebaseAuthProvider.getAccessToken());
    } catch (e) {
      return left(const BaseException('Error sign in ',
          success: false,
          code: null,
          message: '')); // Return left if an error occurs
    }
  }

  @override
  Future<Either<BaseException, UserModel?>> getProfileData() async {
    try {
      firebase.User? user = await firebaseAuthProvider.getCurrentUser();

      if (user == null) {
        return right(null);
      }

      return right(UserModel(
        id: user.uid,
        email: user.email,
        name: user.displayName,
      ));
    } catch (e) {
      return left(const BaseException(
        'Error getting profile data',
        success: false,
        code: null,
        message: '',
      ));
    }
  }

  @override
  Future<Either<BaseException, bool>> signOut() async {
    try {
      await firebaseAuthProvider.signOut();
      return right(true);
    } catch (e) {
      return left(const BaseException(
        'Error loging out',
        success: false,
        code: null,
        message: '',
      ));
    }
  }
}
