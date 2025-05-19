// Implementación corregida de HomePage para resolver el problema de overflow

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/animations/animations.dart';
import 'package:todo_list_app/core/widgets/buttons/floating-button.dart';
import 'package:todo_list_app/core/widgets/drawer/drawer.dart';
import 'package:todo_list_app/core/widgets/drawer/navbar.dart';
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
            child: Obx(
              () {
                controller.refreshTrigger.value;
                return Column(
                  children: [
                    HomeNavbar(),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: kanbanBoard(context),
                    ),
                  ],
                );
              },
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
              fontSize: AppTheme.fontSize.f24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ' ${controller.userInfo.value?.name ?? 'you'}',
            style: TextStyle(
              color: AppTheme.colors.appSecondary,
              fontSize: AppTheme.fontSize.f18,
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
          ),
        ],
      ),
    );
  }

  Widget kanbanBoard(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columnWidth = constraints.maxWidth / 3 - 16.w;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // To Do Column
            _buildColumn(
              context,
              title: 'TO_DO'.tr,
              status: HomeController.STATUS_TODO,
              color: AppTheme.colors.appPrimary,
              width: columnWidth,
              height: constraints.maxHeight - 8.h,
            ),

            // In Progress Column
            _buildColumn(
              context,
              title: 'IN_PROGRESS'.tr,
              status: HomeController.STATUS_IN_PROGRESS,
              color: AppTheme.colors.appSecondary,
              width: columnWidth,
              height: constraints.maxHeight - 8.h,
            ),

            // Done Column
            _buildColumn(
              context,
              title: 'DONE'.tr,
              status: HomeController.STATUS_DONE,
              color: AppTheme.colors.appTertiary,
              width: columnWidth,
              height: constraints.maxHeight - 8.h,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildColumn(
    BuildContext context, {
    required String title,
    required String status,
    required Color color,
    required double width,
    required double height,
  }) {
    return Container(
      margin: EdgeInsets.all(8.w),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado de columna
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppTheme.fontSize.f16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.white,
                ),
              ),
            ),
          ),
          // Contenido de la columna
          Expanded(
            child: StreamBuilder<Either<BaseException, QuerySnapshot>>(
              stream: controller.getNotesByStatus(status),
              builder: (context, snapshot) {
                // Verificar estados de carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: color,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print('Error in StreamBuilder: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.triangleExclamation,
                          color: AppTheme.colors.appAlert,
                          size: 30.r,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'ERROR: ${snapshot.error}',
                          style: TextStyle(color: AppTheme.colors.appAlert),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return _buildEmptyColumn(color);
                }

                // Manejar el Either correctamente
                return snapshot.data!.fold(
                  (exception) {
                    print('BaseException: ${exception.message}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.triangleExclamation,
                            color: AppTheme.colors.appAlert,
                            size: 30.r,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'ERROR: ${exception.message}',
                            style: TextStyle(color: AppTheme.colors.appAlert),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                  (querySnapshot) {
                    return DragTarget<Map<String, dynamic>>(
                      onWillAccept: (data) {
                        print('onWillAccept for $status: $data');
                        if (data == null) return false;
                        if (!data.containsKey('id') ||
                            !data.containsKey('status')) {
                          return false;
                        }
                        if (data['status'] == status) return false;
                        return true;
                      },
                      onAccept: (taskData) {
                        print('Accepted task: ${taskData['id']} to $status');
                        controller.updateTaskStatus(
                          taskData['id'],
                          status,
                        );
                      },
                      builder: (context, candidateData, rejectedData) {
                        // Estilos cuando se está arrastrando sobre la columna
                        final bool isHovering = candidateData.isNotEmpty;

                        // Construir el contenedor principal
                        return Container(
                          decoration: BoxDecoration(
                            color: isHovering
                                ? color.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            border: isHovering
                                ? Border.all(color: color, width: 2.w)
                                : null,
                          ),
                          // Si no hay documentos, mostrar un mensaje "vacío"
                          child: querySnapshot.docs.isEmpty
                              ? _buildEmptyPlaceholder(color)
                              : ListView.builder(
                                  padding: EdgeInsets.all(8.w),
                                  itemCount: querySnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot task =
                                        querySnapshot.docs[index];
                                    return _buildDraggableTask(
                                        context, task, status, color);
                                  },
                                ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Widget para mostrar cuando una columna está vacía
  Widget _buildEmptyPlaceholder(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.clipboardList,
            color: color.withOpacity(0.5),
            size: 30.r,
          ),
          SizedBox(height: 8.h),
          Text(
            'NO_TASKS'.tr,
            style: TextStyle(
              color: color,
              fontSize: AppTheme.fontSize.f14,
            ),
          ),
          Text(
            'DRAG_HERE'.tr,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: AppTheme.fontSize.f12,
            ),
          ),
        ],
      ),
    );
  }

// Widget para mostrar cuando hay errores con la columna
  Widget _buildEmptyColumn(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.clipboardList,
            color: color.withOpacity(0.5),
            size: 30.r,
          ),
          SizedBox(height: 8.h),
          Text(
            'NO_DATA'.tr,
            style: TextStyle(
              color: color,
              fontSize: AppTheme.fontSize.f14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTask(
      BuildContext context, DocumentSnapshot task, String status, Color color) {
    return LongPressDraggable<Map<String, dynamic>>(
      // Datos para el drag
      data: {
        'id': task.id,
        'status': status,
        'title': task['title'] ?? '',
      },
      // Duración del inicio del drag
      delay: Duration(milliseconds: 150),
      // Feedback (lo que se ve al arrastrar)
      feedback: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.28,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color, width: 2.w),
          ),
          child: Text(
            task['title'] ?? 'Sin título',
            style: TextStyle(
              fontSize: AppTheme.fontSize.f14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
      // Aspecto cuando se está arrastrando
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCard(task, color),
      ),
      // Eventos para debugging y feedback
      onDragStarted: () {
        print('Started dragging task: ${task.id} - ${task['title']}');
      },
      onDragEnd: (details) {
        print('Ended dragging task: ${task.id} - ${task['title']}');
      },
      onDraggableCanceled: (velocity, offset) {
        print('Canceled dragging task: ${task.id} - ${task['title']}');
      },
      // Widget normal cuando no se está arrastrando
      child: GestureDetector(
        onTap: () {
          controller.titleController.text = task['title'] ?? '';
          controller.descriptionController.text = task['description'] ?? '';
          controller.completionState.value = task['state'] ?? false;
          controller.taskStatus.value =
              task['status'] ?? HomeController.STATUS_TODO;
          controller.noteId.value = task.id;
          _showBottomSheet(false);
        },
        child: _buildTaskCard(task, color),
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task, Color color) {
    bool isCompleted = task['state'] ?? false;
    DateTime taskDate =
        (task['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    String formattedDate = DateFormat.yMMMd().format(taskDate);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task['title'] ?? 'No title',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize.f14,
                    fontWeight: FontWeight.bold,
                    color: color,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Container(
              //   height: 20.h,
              //   width: 20.w,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(color: color, width: 2),
              //     color: isCompleted ? color : Colors.transparent,
              //   ),
              //   child: isCompleted
              //       ? Icon(
              //           Icons.check,
              //           size: 14.r,
              //           color: AppTheme.colors.white,
              //         )
              //       : null,
              // ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            task['description'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTheme.fontSize.f12,
              color: AppTheme.colors.appSecondary,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: AppTheme.fontSize.f10,
              color: AppTheme.colors.appSecondary,
            ),
          ),
          // if ((task['descriptionTranslated'] as String?) != '' &&
          //     (task['titleTranslated'] as String?) != '')
          //   _buildTranslatedText(task, isCompleted),
        ],
      ),
    );
  }

  // Widget _buildTranslatedText(DocumentSnapshot task, bool isCompleted) {
  //   return Container(
  //     margin: EdgeInsets.only(top: 8.h),
  //     padding: EdgeInsets.all(8.w),
  //     decoration: BoxDecoration(
  //       color: AppTheme.colors.white,
  //       borderRadius: BorderRadius.circular(8.r),
  //       border: Border.all(
  //         color: AppTheme.colors.appTertiary.withOpacity(0.3),
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             FaIcon(
  //               FontAwesomeIcons.language,
  //               color: AppTheme.colors.appTertiary,
  //               size: 12.r,
  //             ),
  //             SizedBox(width: 4.w),
  //             Text(
  //               (task['titleTranslated'] as String?) ?? '',
  //               style: TextStyle(
  //                 fontSize: AppTheme.fontSize.f12,
  //                 fontWeight: FontWeight.bold,
  //                 color: AppTheme.colors.appTertiary,
  //                 decoration: isCompleted ? TextDecoration.lineThrough : null,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 4.h),
  //         Text(
  //           (task['descriptionTranslated'] as String?) ?? '',
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //           style: TextStyle(
  //             fontSize: AppTheme.fontSize.f10,
  //             color: AppTheme.colors.appSecondary,
  //             decoration: isCompleted ? TextDecoration.lineThrough : null,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _showBottomSheet(bool newNote, [void Function()? cb]) async {
    await Get.bottomSheet(
      newNote ? _addBottomSheetItems() : _editBottomSheetItems(),
      elevation: 20,
      // Evitar problemas con el teclado
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
      ),
    );

    cb?.call();
  }

  Widget _addBottomSheetItems() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
        ),
        child: SizedBox(
          height: 420.h,
          child: TaskForm(
            initialCompletionState: false,
            initialStatus: controller.taskStatus.value,
            saveButton: () async {
              final status = controller.taskStatus.value.isNotEmpty
                  ? controller.taskStatus.value
                  : HomeController.STATUS_TODO;

              await controller.addNote(
                NoteParams(
                  controller.titleController.text,
                  controller.descriptionController.text,
                  DateTime.now(),
                  controller.completionState.value,
                  status,
                ),
              );
              // No necesitamos llamar a controller.update() porque addNote ya llama a triggerRefresh()
            },
          ),
        ),
      ),
    );
  }

  Widget _editBottomSheetItems() {
    return Obx(
      () => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 420.h,
            child: TaskForm(
              initialTitle: controller.titleController.text,
              initialDescription: controller.descriptionController.text,
              initialCompletionState: controller.completionState.value,
              initialStatus: controller.taskStatus.value,
              saveButton: () async {
                await controller.updateNote(
                  params: UpdateNoteParams(
                    noteId: controller.noteId.value,
                    title: controller.titleController.text,
                    description: controller.descriptionController.text,
                    date: DateTime.now(),
                    state: controller.completionState.value,
                    language: true,
                    status: controller.taskStatus.value,
                  ),
                );
                // No necesitamos llamar a controller.update() porque updateNote ya llama a triggerRefresh()
              },
              deleteButton: () async {
                await controller.deleteNote(controller.noteId.value);
                // No necesitamos llamar a controller.update() porque deleteNote ya llama a triggerRefresh()
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Form class
class TaskForm extends StatelessWidget {
  final String? initialTitle;
  final String? initialDescription;
  final bool initialCompletionState;
  final String initialStatus;
  final Function saveButton;
  final Function? deleteButton;

  const TaskForm({
    super.key,
    this.initialTitle,
    this.initialDescription,
    required this.initialCompletionState,
    this.initialStatus = 'toDo',
    required this.saveButton,
    this.deleteButton,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    if (initialTitle != null) {
      controller.titleController.text = initialTitle!;
    }

    if (initialDescription != null) {
      controller.descriptionController.text = initialDescription!;
    }

    controller.completionState.value = initialCompletionState;
    controller.taskStatus.value = initialStatus;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppTheme.colors.appPrimary,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'TASK_DETAILS'.tr,
            style: TextStyle(
              fontSize: AppTheme.fontSize.f18,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.appPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // Title field
          TextField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'TITLE'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Description field
          TextField(
            controller: controller.descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'DESCRIPTION'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Status dropdown
          Obx(() => DropdownButtonFormField<String>(
                value: controller.taskStatus.value,
                decoration: InputDecoration(
                  labelText: 'STATUS'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: HomeController.STATUS_TODO,
                    child: Text('TO_DO'.tr),
                  ),
                  DropdownMenuItem(
                    value: HomeController.STATUS_IN_PROGRESS,
                    child: Text('IN_PROGRESS'.tr),
                  ),
                  DropdownMenuItem(
                    value: HomeController.STATUS_DONE,
                    child: Text('DONE'.tr),
                  ),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    controller.taskStatus.value = value;

                    if (value == HomeController.STATUS_DONE) {
                      controller.completionState.value = true;
                    } else if (value == HomeController.STATUS_TODO) {
                      controller.completionState.value = false;
                    }
                  }
                },
              )),
          SizedBox(height: 16.h),

          // Obx(
          //   () => Row(
          //     children: [
          //       Checkbox(
          //         value: controller.completionState.value,
          //         onChanged: (value) {
          //           controller.completionState.value = value ?? false;

          //           if (value == true &&
          //               controller.taskStatus.value !=
          //                   HomeController.STATUS_DONE) {
          //             controller.taskStatus.value = HomeController.STATUS_DONE;
          //           }
          //         },
          //         activeColor: AppTheme.colors.appSecondary,
          //       ),
          //       Text('COMPLETED'.tr),
          //     ],
          //   ),
          // ),
          SizedBox(height: 16.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => saveButton(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.appPrimary,
                  foregroundColor: AppTheme.colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text('SAVE'.tr),
              ),
              if (deleteButton != null)
                ElevatedButton(
                  onPressed: () => deleteButton!(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.appAlert,
                    foregroundColor: AppTheme.colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('DELETE'.tr),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
