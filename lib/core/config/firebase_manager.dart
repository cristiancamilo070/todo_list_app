import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:todo_list_app/firebase_options.dart';

/// Manages Firebase and optionally initializes the messaging system.
class FirebaseManager {
  /// Initializes Firebase and, optionally, the messaging system.
  ///
  /// [initMessaging] - Initialize the messaging system if `true`.
  static Future<void> initializeApp([bool initMessaging = true]) async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // _manageFirebaseCrashlytics();
  }

  // static void _manageFirebaseCrashlytics() {
  //   const fatalError = true;
  //   // Non-async exceptions
  //   FlutterError.onError = (errorDetails) {
  //     // print('errorDetails ~> $errorDetails');
  //     if (fatalError) {
  //       // If you want to record a "fatal" exception
  //       FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  //       // ignore: dead_code
  //     } else {
  //       // If you want to record a "non-fatal" exception
  //       FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  //     }
  //   };
  //   // Async exceptions
  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     if (fatalError) {
  //       // If you want to record a "fatal" exception
  //       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //       // ignore: dead_code
  //     } else {
  //       // If you want to record a "non-fatal" exception
  //       FirebaseCrashlytics.instance.recordError(error, stack);
  //     }
  //     return true;
  //   };
  // }
}
