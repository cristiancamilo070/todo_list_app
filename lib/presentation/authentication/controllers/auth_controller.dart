import 'package:flutter/material.dart';
import 'package:todo_list_app/core/controllers/base_getx_controller.dart';
import 'package:todo_list_app/core/controllers/main_controller.dart';

import 'package:get/get.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_in_password_use_case.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_in_with_google_usecase.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_up_password_use_case.dart';

class AuthController extends BaseGetxController {
  final Rx<String> verificationEvent = Rx("");
  final MainController _mainController = Get.find();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Future<void> signInWithApple() async {
  //   showLoading();
  //   final useCase = Get.find<SignInWithAppleUseCase>();
  //   final result = await useCase.execute();
  //   closeLoading();
  //   result.fold((l) {
  //     showErrorMessage('Error', l.message);
  //   }, (r) async {
  //     if (r) {
  //       await _mainController.getUserInfo();
  //     } else {
  //       showErrorMessage('Error', 'UNEXPECTED_ERROR'.tr);
  //     }
  //   });
  // }

  Future<void> signInWithGoogle() async {
    showLoading();
    final useCase = Get.find<SignInWithGoogleUseCase>();
    final result = await useCase.execute();
    closeLoading();
    result.fold((l) {
      showErrorMessage('ATENTION'.tr, l.message);
    }, (r) async {
      if (r) {
        await _mainController.getUserInfo(fromSignIn: true);
      } else {
        showErrorMessage('ATENTION'.tr, 'UNEXPECTED_ERROR'.tr);
      }
    });
  }

  Future<void> signUpWithPassword(String email, String password) async {
    final useCase = Get.find<SignupPasswordUseCase>();
    final result = await useCase.execute(LoginParams(email, password));
    result.fold((error) {
      showErrorMessage('Error', 'Unexpected error');
    }, (userInfo) async {
      debugPrint('userInfo: $userInfo.email');

      showSuccessMessage("WELCOME".tr, '');
      await _mainController.getUserInfo(fromSignIn: true);
    });
  }

  Future<void> signInWithPassword(String email, String password) async {
    final useCase = Get.find<SignInPasswordUseCase>();
    final result = await useCase.execute(LoginParams(email, password));
    result.fold((error) {
      showErrorMessage('Error', 'Wrong email or password');
    }, (userInfo) async {
      debugPrint('userInfo: $userInfo.email');

      showSuccessMessage("WELCOME".tr, '');

      await _mainController.getUserInfo(fromSignIn: true);
    });
  }
}
