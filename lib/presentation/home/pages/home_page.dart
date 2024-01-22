import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/buttons/floating-button.dart';
import 'package:todo_list_app/core/widgets/animations/animations.dart';
import 'package:todo_list_app/core/widgets/drawer/drawer.dart';
import 'package:todo_list_app/core/widgets/drawer/navbar.dart';
import 'package:todo_list_app/core/widgets/forms/note_form.dart';
import 'package:todo_list_app/domain/exceptions/base_exception.dart';
import 'package:todo_list_app/domain/use_cases/firestore/add_note_use_case.dart';
import 'package:todo_list_app/domain/use_cases/firestore/edit_note_use_case.dart';
import 'package:todo_list_app/presentation/home/controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  final homeAnimationsController = Get.put(HomeAnimationsController());

  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    startHomeAnimations();
    return AdvancedDrawer(
      backdropColor: AppTheme.colors.appTertiary,
      controller: controller.advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      openRatio: 0.66,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50.r)),
      ),
      drawer: const HomeDrawer(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.colors.white,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  AppTheme.colors.white,
                  AppTheme.colors.white,
                  AppTheme.colors.appQuaternary.withOpacity(0.2),
                  AppTheme.colors.white,
                  AppTheme.colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                HomeNavbar(),
                header(),
                heightSpace20,
                body(),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(right: 15.w, bottom: 25.w),
          child: HomeFloatingButton(
            onTap: () async {
              await _showBottomSheet(true);
            },
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Obx(
      () => Column(
        children: [
          Text(
            'TODO_LIST_OF'.tr,
            style: TextStyle(
              color: AppTheme.colors.appPrimary,
              fontSize: AppTheme.fontSize.f36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ' ${controller.userInfo.value?.name}',
            style: TextStyle(
              color: AppTheme.colors.appSecondary,
              fontSize: AppTheme.fontSize.f24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: AppTheme.colors.appQuaternary.withOpacity(1),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget body() {
    return Expanded(
      child: SizedBox(
        child: StreamBuilder<Either<BaseException, QuerySnapshot>>(
          stream: controller.getNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.colors.appQuaternary,
                  strokeWidth: 10,
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  'No data available.',
                  style: AppTheme.style.bold
                      .copyWith(color: AppTheme.colors.appSecondary),
                ),
              );
            } else {
              QuerySnapshot querySnapshot =
                  snapshot.data!.getOrElse(() => throw Exception());

              if (querySnapshot.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "NO_NOTES".tr,
                        style: AppTheme.style.bold.copyWith(
                          color: AppTheme.colors.appSecondary,
                          fontSize: AppTheme.fontSize.f14,
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.noteSticky,
                        color: AppTheme.colors.appSecondary,
                        size: 30.r,
                      )
                    ],
                  ),
                );
              }

              return ListView.separated(
                separatorBuilder: (context, index) => heightSpace16,
                itemCount: querySnapshot.docs.length,
                itemBuilder: (context, index) {
                  var note = querySnapshot.docs[index];

                  return buildNoteItem(note);
                },
              ).paddingSymmetric(horizontal: 16.w);
            }
          },
        ),
      ),
    );
  }

  Widget buildNoteItem(DocumentSnapshot note) {
    bool isChecked = note['state'] ?? false;

    DateTime noteDate = (note['date'] as Timestamp).toDate();

    String formattedDate = DateFormat.yMMMd().format(noteDate);
    String formattedTime = DateFormat('HH:mm').format(noteDate);

    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (_) async {
              await controller.updateNote(
                params: UpdateNoteParams(
                  noteId: note.id,
                  title: note['title'],
                  description: note['description'],
                  date: DateTime.now(),
                  state: isChecked,
                  language: note['language'] ? false : true,
                ),
                fromTranslate: true,
              );
            },
            backgroundColor: AppTheme.colors.appTertiary,
            foregroundColor: Colors.white,
            icon: FontAwesomeIcons.language,
            label: 'Translate',
          ),
          SlidableAction(
            onPressed: (_) async {
              await controller.deleteNote(note.id);
            },
            backgroundColor: AppTheme.colors.appAlert,
            foregroundColor: Colors.white,
            icon: FontAwesomeIcons.trash,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10.r),
              topRight: Radius.circular(10.r),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () async {
          controller.titleController.text = note['title'];
          controller.descriptionController.text = note['description'];
          controller.completionState.value = isChecked;

          controller.noteId.value = note.id;
          await _showBottomSheet(false);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isChecked ? AppTheme.colors.white : AppTheme.colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.appPrimary.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            title: Text(note['title'],
                style: AppTheme.style.bold.copyWith(
                  fontSize: AppTheme.fontSize.f16,
                  color: isChecked
                      ? AppTheme.colors.appPrimary
                      : AppTheme.colors.appPrimary,
                )).paddingOnly(top: 4.h),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpace2,
                Text(
                  note['description'],
                  style: TextStyle(
                    color: isChecked
                        ? AppTheme.colors.appSecondary
                        : AppTheme.colors.appPrimary,
                  ),
                ),
                heightSpace4,
                Text.rich(
                  TextSpan(
                    text: '$formattedDate ',
                    style: AppTheme.style.bold.copyWith(
                      color: AppTheme.colors.appSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: formattedTime,
                        style: AppTheme.style.bold.copyWith(
                          color: AppTheme.colors.appSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                heightSpace4,
                if (note['descriptionTranslated'] != '' ||
                    note['titleTranslated'] != '')
                  ListTile(
                    title: FaIcon(
                      FontAwesomeIcons.language,
                      color: AppTheme.colors.appTertiary,
                    ),
                    subtitle: translatedText(
                      note: note,
                      isChecked: isChecked,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                heightSpace4,
              ],
            ),
            trailing: Checkbox(
              value: isChecked,
              onChanged: (value) async {
                controller.titleController.text = note['title'];
                controller.descriptionController.text = note['description'];
                controller.completionState.value = isChecked;

                controller.noteId.value = note.id;
                await _showBottomSheet(false);
              },
              activeColor: AppTheme.colors.appSecondary,
              checkColor: AppTheme.colors.white,
            ),
            tileColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget translatedText(
      {required DocumentSnapshot note, required bool isChecked}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.appPrimary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note['titleTranslated'],
              style: AppTheme.style.bold.copyWith(
                fontSize: AppTheme.fontSize.f12,
                color: isChecked
                    ? AppTheme.colors.appPrimary
                    : AppTheme.colors.appPrimary,
              )).paddingOnly(top: 4.h),
          heightSpace4,
          Text(
            note['descriptionTranslated'],
            style: TextStyle(
              fontSize: AppTheme.fontSize.f12,
              color: isChecked
                  ? AppTheme.colors.appSecondary
                  : AppTheme.colors.appPrimary,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 8.w),
    );
  }

  Future<void> _showBottomSheet(bool newNote, [void Function()? cb]) async {
    await Get.bottomSheet(
      (newNote) ? _addBottomSheetItems() : _editBottomSheetItems(),
      elevation: 34,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
    );

    cb?.call();
  }

  Widget _addBottomSheetItems() {
    return SingleChildScrollView(
      child: SizedBox(
        height: 320.h,
        child: NoteForm(
          initialCompletionState: false,
          saveButton: () async {
            await controller.addNote(
              NoteParams(
                controller.titleController.text,
                controller.descriptionController.text,
                DateTime.now(),
                controller.completionState.value,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _editBottomSheetItems() {
    return Obx(
      () => SingleChildScrollView(
        child: SizedBox(
          height: 360.h,
          child: NoteForm(
            initialTitle: controller.titleController.text,
            initialDescription: controller.descriptionController.text,
            initialCompletionState: controller.completionState.value,
            saveButton: () async {
              await controller.updateNote(
                params: UpdateNoteParams(
                  noteId: controller.noteId.value,
                  title: controller.titleController.text,
                  description: controller.descriptionController.text,
                  date: DateTime.now(),
                  state: controller.completionState.value,
                  language: true,
                ),
              );
            },
            deleteButton: () async {
              await controller.deleteNote(controller.noteId.value);
            },
          ),
        ),
      ),
    );
  }
}
