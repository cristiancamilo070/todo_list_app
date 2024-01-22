import 'package:get/get.dart';
import 'package:todo_list_app/core/controllers/main_controller.dart';
import 'package:todo_list_app/core/localization/repositories/localization_repository.dart';
import 'package:todo_list_app/data/providers/firestore/firestore_provider.dart';
import 'package:todo_list_app/data/repositories/auth/profile_repository_impl.dart';
import 'package:todo_list_app/data/repositories/firestore/firestore_repository_impl.dart';
import 'package:todo_list_app/data/repositories/security/secure_storage_repository_impl.dart';
import 'package:todo_list_app/data/repositories/security/shared_preference_repository_impl.dart';
import 'package:todo_list_app/data/providers/auth/firebase_auth_provider.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';
import 'package:todo_list_app/domain/repositories/security/secure_storage_repository.dart';
import 'package:todo_list_app/domain/repositories/security/shared_preference_repository.dart';

class DependencyCreator {
  static initialize() {
    Get.put(LocalizationRepository(), permanent: true);
    Get.put(FirebaseAuthProvider(), permanent: true);
    Get.put(FirestoreProvider(), permanent: true);

    Get.put<SecureStorageRepository>(
      SecureStorageRepositoryImpl(),
      permanent: true,
    );
    Get.put<FirestoreRepository>(
      FirestoreRepositoryImpl(Get.find<FirestoreProvider>()),
      permanent: true,
    );
    Get.put<SharedPreferencesRepository>(
      SharedPreferencesRepositoryImpl(),
      permanent: true,
    );
    Get.lazyPut(
      () => FirebaseAuthProvider(),
      fenix: true,
    );
    Get.put(
      MainController(
        Get.put<ProfileRepository>(
          ProfileRepositoryImpl(
            FirebaseAuthProvider(),
          ),
          permanent: true,
        ),
      ),
      permanent: true,
    );
  }
}
