// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/data/providers/auth/firebase_auth_provider.dart';
import 'package:todo_list_app/domain/repositories/security/secure_storage_repository.dart';
import 'package:todo_list_app/domain/use_cases/base_use_cases.dart';

class SignInWithGoogleUseCase extends BaseUseCasesNoParams<bool> {
  final FirebaseAuthProvider _authRepository;
  final SecureStorageRepository _secureStorageRepository;

  SignInWithGoogleUseCase(
    this._authRepository,
    this._secureStorageRepository,
  );

  @override
  Future<Either<BaseException, bool>> execute() async {
    try {
      print('before refreshToken');
      final refreshToken = await _authRepository.signInWithGoogle();
      print('refreshToken ~> $refreshToken');

      await _secureStorageRepository.saveToken(refreshToken ?? '');

      return const Right(true);
    } on PlatformException catch (e, stack) {
      debugPrintStack(label: e.toString(), stackTrace: stack);
      return const Right(false);
    }
  }
}
