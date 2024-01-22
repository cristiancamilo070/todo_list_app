import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:todo_list_app/core/controllers/base_getx_controller.dart';
import 'package:todo_list_app/core/routes/app_routes.dart';
import 'package:todo_list_app/domain/models/user_model.dart';
import 'package:todo_list_app/domain/repositories/auth/profile_repository.dart';
import 'package:todo_list_app/domain/use_cases/auth/get_profile_use_case.dart';

class MainController extends BaseGetxController {
  final ProfileRepository _profileRepository;

  final RxString _appVersion = "".obs;

  final RxBool isReadyDependencies = false.obs;

  MainController(
    this._profileRepository,
  );

  @override
  void onInit() {
    super.onInit();

    _initDependencies();
  }

  String get versionApp {
    return "${'VERSION'.tr.toUpperCase()} ${_appVersion.value}";
  }

  Future<void> _initDependencies() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _appVersion(packageInfo.version);

    await Future.wait([]);

    isReadyDependencies(true);
  }

  Future<UserModel?> getUserInfo({required bool fromSignIn}) async {
    showLoading();
    final useCase = GetProfileUseCase(_profileRepository);
    final result = await useCase.execute();
    UserModel? userModel;
    closeLoading();
    result.fold((l) {
      showErrorMessage('Error', l.message);
      Get.offAllNamed(RoutesPaths.signInPage);
    }, (r) async {
      if (r == null) {
        Get.offAllNamed(RoutesPaths.signInPage);
        userModel = null;
      } else {
        if (fromSignIn) {
          Get.offAllNamed(RoutesPaths.homePage);
        }
        userModel = r;
      }
    });
    return userModel;
  }
}
