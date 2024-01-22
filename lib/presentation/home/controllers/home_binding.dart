import 'package:get/get.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/repositories/firestore/firestore_repository.dart';
import 'package:todo_list_app/domain/use_cases/auth/log_out_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/add_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/delete_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/edit_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/get_notes_use_case.dart';
import 'package:todo_list_app/presentation/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(
      () => LogOutUseCase(
        Get.find<ProfileRepository>(),
      ),
    );
    Get.lazyPut(
      () => AddNoteUseCase(
        Get.find<FirestoreRepository>(),
      ),
    );
    Get.lazyPut(
      () => GetNotesUseCase(
        Get.find<FirestoreRepository>(),
      ),
    );
    Get.lazyPut(
      () => UpdateNoteUseCase(
        Get.find<FirestoreRepository>(),
      ),
    );
    Get.lazyPut(
      () => DeleteNoteUseCase(
        Get.find<FirestoreRepository>(),
      ),
    );
  }
}
