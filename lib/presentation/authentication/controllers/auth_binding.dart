import 'package:get/get.dart';
import 'package:todo_list_app/data/providers/auth/firebase_auth_provider.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/repositories/security/secure_storage_repository.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_in_password_use_case.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_in_with_google_usecase.dart';
import 'package:todo_list_app/domain/use_cases/auth/sign_up_password_use_case.dart';
import 'package:todo_list_app/presentation/authentication/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(
      () => SignInWithGoogleUseCase(
        Get.find<FirebaseAuthProvider>(),
        Get.find<SecureStorageRepository>(),
      ),
    );
    Get.lazyPut(
      () => SignInPasswordUseCase(
        Get.find<ProfileRepository>(),
      ),
    );
    Get.lazyPut(
      () => SignupPasswordUseCase(
        Get.find<ProfileRepository>(),
      ),
    );
  }
}
