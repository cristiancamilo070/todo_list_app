// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/core/config/dependency_creator.dart';
import 'package:todo_list_app/core/config/firebase_manager.dart';
import 'package:todo_list_app/core/localization/repositories/localization_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_list_app/core/routes/app_routes.dart';
import 'package:todo_list_app/core/routes/path_routes.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: AppTheme.colors.appPrimary,
    systemNavigationBarColor: AppTheme.colors.appSecondary,
    systemNavigationBarDividerColor: AppTheme.colors.appSecondary,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));

  /// Initialize Firebase
  await FirebaseManager.initializeApp();

  /// Init dependency
  DependencyCreator.initialize();

  /// Init localization repository
  await LocalizationRepository.initializeLanguages();

  /// Run App
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: AppTheme.colors.white,
          fontFamily: 'Montserrat',
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        title: 'toDO List',
        builder: EasyLoading.init(),
        translations: LocalizationRepository(),
        defaultTransition: Transition.rightToLeft,
        locale: Get.deviceLocale,
        getPages: PagesManager.pages,
        initialRoute: RoutesPaths.splashPage,
        fallbackLocale: const Locale('en'),
        supportedLocales: LocalizationRepository.supportedLocales,
        localeResolutionCallback:
            LocalizationRepository.localeResolutionCallback,
      ),
    ),
  );
}
