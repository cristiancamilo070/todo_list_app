// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:todo_list_app/core/controllers/base_getx_controller.dart';
import 'package:todo_list_app/core/controllers/main_controller.dart';

import 'package:get/get.dart';
import 'package:todo_list_app/core/routes/app_routes.dart';
import 'package:todo_list_app/domain/models/user_model.dart';
import 'package:todo_list_app/domain/use_cases/auth/log_out_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/add_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/delete_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/edit_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/get_notes_use_case.dart';

class HomeController extends BaseGetxController {
  late final AddNoteUseCase _addNoteUseCase;
  late final UpdateNoteUseCase _updateNoteUseCase;
  late final DeleteNoteUseCase _deleteNoteUseCase;
  late final GetNotesUseCase _getNotesUseCase;

  late final LogOutUseCase _logOutUseCase;

  final Rx<String> verificationEvent = Rx("");
  final MainController _mainController = Get.find();
  Rx<UserModel?> userInfo = Rx<UserModel?>(null);
  final advancedDrawerController = AdvancedDrawerController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxBool completionState = false.obs;
  RxString noteId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _addNoteUseCase = Get.find<AddNoteUseCase>();
    _logOutUseCase = Get.find<LogOutUseCase>();
    _deleteNoteUseCase = Get.find<DeleteNoteUseCase>();
    _getNotesUseCase = Get.find<GetNotesUseCase>();
    _updateNoteUseCase = Get.find<UpdateNoteUseCase>();

    getUser();
  }

  Future<void> logOut() async {
    await _logOutUseCase.execute();
    Get.offAndToNamed(RoutesPaths.signInPage);
  }

  Future<void> addNote(NoteParams params) async {
    final result = await _addNoteUseCase.execute(params);
    result.fold((l) {
      return false;
    }, (r) {
      showLoading();
      Get.back();
      showSuccessMessage("SAVED_SUCCESS".tr, '');
      titleController.clear();
      descriptionController.clear();
      completionState.value = false;
      closeLoading();
      return true;
    });
  }

  Future<void> updateNote(
      {required UpdateNoteParams params, bool fromTranslate = false}) async {
    final result = await _updateNoteUseCase.execute(params);
    result.fold((l) {
      return false;
    }, (r) {
      showLoading();
      Get.back();
      showSuccessMessage(
        fromTranslate ? "TRA_IN_PROGRESS".tr : "SAVED_SUCCESS".tr,
        fromTranslate ? "TRA_IN_PROGRESS_DESC".tr : '',
      );
      titleController.clear();
      descriptionController.clear();
      completionState.value = false;
      closeLoading();
      return true;
    });
  }

  Future<void> deleteNote(String params) async {
    final result = await _deleteNoteUseCase.execute(params);
    result.fold((l) {
      return false;
    }, (r) {
      showLoading();
      Get.back();
      showErrorMessage("DELETE_SUCCESS".tr, '');
      titleController.clear();
      descriptionController.clear();
      completionState.value = false;
      closeLoading();
      return true;
    });
  }

  getNotes() {
    return _getNotesUseCase.execute();
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
}
