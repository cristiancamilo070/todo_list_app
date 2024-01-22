// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/buttons/primary_button.dart';
import 'package:todo_list_app/core/widgets/inputs/app_inputs.dart';
import 'package:todo_list_app/presentation/home/controllers/home_controller.dart';

class NoteForm extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final bool? initialCompletionState;
  final Function() saveButton;
  final Function()? deleteButton;

  const NoteForm({
    Key? key,
    this.initialTitle,
    this.initialDescription,
    this.initialCompletionState,
    this.deleteButton,
    required this.saveButton,
  }) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('NOTE_DETAILS'.tr,
              style: AppTheme.style.bold.copyWith(
                fontSize: AppTheme.fontSize.f20,
                color: AppTheme.colors.appPrimary,
              )),
          heightSpace20,
          AppTextField(
            inputsParams: AppInputParameters(
              controller: homeController.titleController,
              hintText: 'TITLE'.tr,
              inputType: AppInputType.email,
            ),
          ),
          heightSpace20,
          AppTextField(
            inputsParams: AppInputParameters(
              maxLines: 3,
              controller: homeController.descriptionController,
              hintText: 'DESCRIPTION'.tr,
              inputType: AppInputType.text,
            ),
          ),
          heightSpace8,
          Obx(
            () => Row(
              children: [
                Text('COMPLETED'.tr),
                Checkbox(
                  value: homeController.completionState.value,
                  checkColor: AppTheme.colors.white,
                  activeColor: AppTheme.colors.appSecondary,
                  onChanged: (value) {
                    homeController.completionState.value = value ?? false;
                  },
                ),
              ],
            ),
          ),
          heightSpace8,
          PrimaryButton(
            text: 'SAVE'.tr,
            color: AppTheme.colors.appPrimary,
            onPressed: widget.saveButton,
          ),
          if (widget.deleteButton != null) heightSpace8,
          if (widget.deleteButton != null)
            PrimaryButton(
              text: 'DELETE'.tr,
              color: AppTheme.colors.appAlert,
              onPressed: widget.deleteButton ?? () {},
            ),
        ],
      ),
    );
  }
}
