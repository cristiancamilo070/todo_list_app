import 'package:get/get.dart';
import 'package:todo_list_app/core/routes/app_routes.dart';
import 'package:todo_list_app/presentation/authentication/controllers/auth_binding.dart';
import 'package:todo_list_app/presentation/authentication/pages/sign_in_page.dart';
import 'package:todo_list_app/presentation/authentication/pages/sign_up_page.dart';
import 'package:todo_list_app/presentation/home/controllers/home_binding.dart';
import 'package:todo_list_app/presentation/home/pages/home_page.dart';
import 'package:todo_list_app/presentation/splash_page.dart';

/// The PagesManager class is responsible for managing the list of pages in a Dart application,
/// including their names, associated widgets, and bindings.
class PagesManager {
  PagesManager._();
  static final List<GetPage> pages = [
    GetPage(
      name: RoutesPaths.splashPage,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: RoutesPaths.signInPage,
      page: () => const SignInPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: RoutesPaths.signUpPage,
      page: () => const SignUpPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: RoutesPaths.homePage,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
