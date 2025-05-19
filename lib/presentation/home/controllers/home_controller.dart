// Implementación corregida del HomeController

// ignore_for_file: avoid_print, constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:todo_list_app/core/controllers/base_getx_controller.dart';
import 'package:todo_list_app/core/controllers/main_controller.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/core/routes/app_routes.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/models/user_model.dart';
import 'package:todo_list_app/domain/use_cases/auth/log_out_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/add_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/delete_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/edit_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/get_notes_use_case.dart';

class HomeController extends BaseGetxController {
  // Los servicios y casos de uso se mantienen igual
  late final AddNoteUseCase _addNoteUseCase;
  late final UpdateNoteUseCase _updateNoteUseCase;
  late final DeleteNoteUseCase _deleteNoteUseCase;
  // late final GetNotesUseCase _getNotesUseCase;
  late final LogOutUseCase _logOutUseCase;

  // Variables observables existentes
  final Rx<String> verificationEvent = Rx("");
  final MainController _mainController = Get.find();
  Rx<UserModel?> userInfo = Rx<UserModel?>(null);
  final advancedDrawerController = AdvancedDrawerController();

  // Convertir controladores de texto a contenido observable
  Rx<String> titleText = "".obs;
  Rx<String> descriptionText = "".obs;
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  // Variables observables existentes
  RxBool completionState = false.obs;
  RxString noteId = ''.obs;
  RxString taskStatus = 'toDo'.obs;

  // Nuevo trigger para forzar actualizaciones
  RxBool refreshTrigger = false.obs;

  // Nuevas listas observables para las tareas por estado
  RxList<DocumentSnapshot> todoTasks = <DocumentSnapshot>[].obs;
  RxList<DocumentSnapshot> inProgressTasks = <DocumentSnapshot>[].obs;
  RxList<DocumentSnapshot> doneTasks = <DocumentSnapshot>[].obs;

  static const String STATUS_TODO = 'toDo';
  static const String STATUS_IN_PROGRESS = 'inProgress';
  static const String STATUS_DONE = 'done';

  @override
  void onInit() {
    super.onInit();
    _addNoteUseCase = Get.find<AddNoteUseCase>();
    _logOutUseCase = Get.find<LogOutUseCase>();
    _deleteNoteUseCase = Get.find<DeleteNoteUseCase>();
    // _getNotesUseCase = Get.find<GetNotesUseCase>();
    _updateNoteUseCase = Get.find<UpdateNoteUseCase>();

    titleController = TextEditingController();
    descriptionController = TextEditingController();
    titleController.addListener(() {
      titleText.value = titleController.text;
    });

    descriptionController.addListener(() {
      descriptionText.value = descriptionController.text;
    });

    taskStatus.value = STATUS_TODO;

    ever(taskStatus, (_) => triggerRefresh());

    _initTaskListeners();

    getUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      migrateExistingTasks();
    });
  }

  void _initTaskListeners() {
    // Escuchar tareas "to do"
    getNotesByStatus(STATUS_TODO).listen((either) {
      either
          .fold((error) => print('Error getting todo tasks: ${error.message}'),
              (snapshot) {
        todoTasks.value = snapshot.docs;
      });
    });

    // Escuchar tareas "in progress"
    getNotesByStatus(STATUS_IN_PROGRESS).listen((either) {
      either.fold(
          (error) => print('Error getting in progress tasks: ${error.message}'),
          (snapshot) {
        inProgressTasks.value = snapshot.docs;
      });
    });

    // Escuchar tareas "done"
    getNotesByStatus(STATUS_DONE).listen((either) {
      either
          .fold((error) => print('Error getting done tasks: ${error.message}'),
              (snapshot) {
        doneTasks.value = snapshot.docs;
      });
    });
  }

  Future<void> logOut() async {
    await _logOutUseCase.execute();
    Get.offAndToNamed(RoutesPaths.signInPage);
  }

  // Función para forzar actualización
  void triggerRefresh() {
    refreshTrigger.value = !refreshTrigger.value;
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    titleText.value = '';
    descriptionText.value = '';
    completionState.value = false;
    taskStatus.value = STATUS_TODO;
    noteId.value = '';
  }

  Future<void> addNote(NoteParams params) async {
    try {
      showLoading();
      final result = await _addNoteUseCase.execute(params);
      closeLoading();

      result.fold((error) {
        showErrorMessage("ERROR".tr, error.message);
        return false;
      }, (_) {
        Get.back();
        showSuccessMessage("SAVED_SUCCESS".tr, '');
        clearForm();
        triggerRefresh();
        return true;
      });
    } catch (e) {
      closeLoading();
      showErrorMessage("ERROR".tr, e.toString());
    }
  }

  Future<void> updateNote(
      {required UpdateNoteParams params, bool fromTranslate = false}) async {
    try {
      showLoading();
      final result = await _updateNoteUseCase.execute(params);
      closeLoading();

      result.fold((error) {
        showErrorMessage("ERROR".tr, error.message);
        return false;
      }, (_) {
        Get.back();
        showSuccessMessage(
          fromTranslate ? "TRA_IN_PROGRESS".tr : "SAVED_SUCCESS".tr,
          fromTranslate ? "TRA_IN_PROGRESS_DESC".tr : '',
        );
        clearForm();
        triggerRefresh();
        return true;
      });
    } catch (e) {
      closeLoading();
      showErrorMessage("ERROR".tr, e.toString());
    }
  }

  Future<void> updateTaskStatus(String noteId, String newStatus) async {
    try {
      print('Updating task $noteId to status: $newStatus');
      showLoading();

      // Comprobar si el documento existe
      final taskSnapshot =
          await FirebaseFirestore.instance.collection('todo').doc(noteId).get();

      if (!taskSnapshot.exists || taskSnapshot.data() == null) {
        closeLoading();
        print('Task not found: $noteId');
        showErrorMessage("ERROR".tr, "TASK_NOT_FOUND".tr);
        return;
      }

      final data = taskSnapshot.data()!;
      print('Current task data: $data');

      final previousStatus = data['status'];
      print('Previous status: $previousStatus, New status: $newStatus');

      if (previousStatus == newStatus) {
        closeLoading();
        print('Status unchanged');
        return;
      }

      await FirebaseFirestore.instance.collection('todo').doc(noteId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Status updated successfully in Firestore');
      closeLoading();

      // Forzar actualización de listas
      triggerRefresh();

      showSuccessMessage("STATUS_UPDATED".tr, '');
    } catch (e) {
      closeLoading();
      print('Error updating task status: $e');
      print('Stack trace: ${StackTrace.current}');
      showErrorMessage("ERROR".tr, e.toString());
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      showLoading();
      final result = await _deleteNoteUseCase.execute(noteId);

      result.fold((error) {
        closeLoading();
        showErrorMessage("ERROR".tr, error.message);
        return false;
      }, (_) {
        closeLoading();
        Get.back();
        clearForm();
        triggerRefresh();
        showSuccessMessage("DELETE_SUCCESS".tr, '');
        return true;
      });
    } catch (e) {
      closeLoading();
      showErrorMessage("ERROR".tr, e.toString());
    }
  }

  // El resto de métodos se mantienen igual...

  Stream<Either<BaseException, QuerySnapshot>> getNotesByStatus(String status) {
    try {
      print('Getting notes with status: $status');
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print('User ID: ${user.uid}');

        // Crear un stream para depuración
        final stream = FirebaseFirestore.instance
            .collection('todo')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: status)
            .orderBy('date', descending: true)
            .snapshots();

        // Añadir listener para debugging
        stream.listen((snapshot) {
          print(
              'Stream update for status $status: ${snapshot.docs.length} docs');
          if (snapshot.docs.isNotEmpty) {
            print('First doc: ${snapshot.docs.first.data()}');
          }
        }, onError: (error) {
          print('Stream error in listener: $error');
        });

        return stream.map<Either<BaseException, QuerySnapshot>>((snapshot) {
          print(
              'Mapping snapshot for status $status with ${snapshot.docs.length} docs');
          return right(snapshot);
        }).handleError((error) {
          print('Stream handleError for status $status: $error');
          return left(
            BaseException(
              'Error en la consulta',
              message: error.toString(),
              success: false,
              code: null,
            ),
          );
        });
      } else {
        print('User not logged in when getting notes with status: $status');
        return Stream.value(
          left(
            const BaseException(
              'Error getting notes',
              message: 'User not logged in',
              success: false,
              code: null,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in getNotesByStatus for status $status: $e');
      print('Stack trace: ${StackTrace.current}');
      return Stream.value(
        left(
          BaseException(
            'Error getting notes by status',
            message: e.toString(),
            success: false,
            code: null,
          ),
        ),
      );
    }
  }

  Future<void> getUser() async {
    UserModel? result = await _mainController.getUserInfo(fromSignIn: false);
    if (result != null) {
      userInfo(result);
      print(userInfo.value);
    } else {
      print("User info is null");
    }
  }

  Future<void> migrateExistingTasks() async {
    try {
      print('Starting task migration...');
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('Cannot migrate: User is null');
        return;
      }

      print('Checking for tasks without status for user: ${user.uid}');

      final QuerySnapshot sampleTask = await firestore
          .collection('todo')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (sampleTask.docs.isNotEmpty) {
        print('Sample task fields: ${sampleTask.docs.first.data()}');
      } else {
        print('No tasks found for this user');
      }

      final QuerySnapshot tasksToMigrate = await firestore
          .collection('todo')
          .where('userId', isEqualTo: user.uid)
          .get();

      print('Found ${tasksToMigrate.docs.length} total tasks');

      List<DocumentSnapshot> tasksNeedingMigration = [];

      for (var doc in tasksToMigrate.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('status')) {
          tasksNeedingMigration.add(doc);
        }
      }

      print('Found ${tasksNeedingMigration.length} tasks that need migration');

      if (tasksNeedingMigration.isEmpty) {
        int todoCount = 0, inProgressCount = 0, doneCount = 0, unknownCount = 0;

        for (var doc in tasksToMigrate.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('status')) {
            switch (data['status']) {
              case STATUS_TODO:
                todoCount++;
                break;
              case STATUS_IN_PROGRESS:
                inProgressCount++;
                break;
              case STATUS_DONE:
                doneCount++;
                break;
              default:
                unknownCount++;
                break;
            }
          }
        }

        print(
            'Tasks by status: ToDo: $todoCount, InProgress: $inProgressCount, Done: $doneCount, Unknown: $unknownCount');
        print('No tasks need migration');
        return;
      }

      final batch = firestore.batch();
      int count = 0;

      for (var doc in tasksNeedingMigration) {
        final data = doc.data() as Map<String, dynamic>;
        final bool isCompleted = data['state'] ?? false;
        final String defaultStatus = isCompleted ? STATUS_DONE : STATUS_TODO;

        print('Migrating task ${doc.id} to status: $defaultStatus');
        batch.update(doc.reference, {'status': defaultStatus});
        count++;

        if (count >= 400) {
          await batch.commit();
          print('Committed batch of $count tasks');
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
        print('Committed final batch of $count tasks');
      }

      print('Successfully migrated ${tasksNeedingMigration.length} tasks');

      await Future.delayed(Duration(seconds: 2));
      final QuerySnapshot postMigrationCheck = await firestore
          .collection('todo')
          .where('userId', isEqualTo: user.uid)
          .get();

      int todoCount = 0, inProgressCount = 0, doneCount = 0, noStatusCount = 0;

      for (var doc in postMigrationCheck.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('status')) {
          switch (data['status']) {
            case STATUS_TODO:
              todoCount++;
              break;
            case STATUS_IN_PROGRESS:
              inProgressCount++;
              break;
            case STATUS_DONE:
              doneCount++;
              break;
          }
        } else {
          noStatusCount++;
        }
      }

      print(
          'Post-migration status: ToDo: $todoCount, InProgress: $inProgressCount, Done: $doneCount, No Status: $noStatusCount');
    } catch (e) {
      print('Error during task migration: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
}
