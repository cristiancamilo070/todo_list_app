// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/core/routes/app_routes.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/appbar/custom_app_bar.dart';
import 'package:todo_list_app/core/widgets/buttons/primary_button.dart';
import 'package:todo_list_app/core/widgets/buttons/gmail_social_button.dart';
import 'package:todo_list_app/core/widgets/inputs/app_inputs.dart';
import 'package:todo_list_app/presentation/authentication/controllers/auth_controller.dart';

class SignInPage extends GetView<AuthController> {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bodyContent(),
          loginBottoms(),
        ],
      ),
    );
  }

  Widget bodyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomAppBar(
          title: 'WELCOME'.tr,
        ),
        heightSpace16,
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.colors.appPrimary.withOpacity(0.9),
                  AppTheme.colors.appSecondary.withOpacity(0.7),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: FaIcon(
              FontAwesomeIcons.solidNoteSticky,
              color: AppTheme.colors.white,
              size: 90.r,
            ),
          ),
        ),
        heightSpace30,
        AppTextFormField(
          inputsParams: AppInputParameters(
            controller: controller.emailController,
            hintText: 'EMAIL'.tr,
            inputType: AppInputType.email,
          ),
        ).paddingSymmetric(horizontal: 16.w),
        heightSpace30,
        AppTextFormField(
          inputsParams: AppInputParameters(
            controller: controller.passwordController,
            hintText: 'PASSWORD'.tr,
            inputType: AppInputType.password,
            obscureText: true,
          ),
        ).paddingSymmetric(horizontal: 16.w),
      ],
    );
  }

  Widget loginBottoms() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            text: 'LOG_IN'.tr,
            onPressed: () {
              if (controller.emailController.value.text.isEmail) {
                controller.signInWithPassword(
                  controller.emailController.value.text,
                  controller.emailController.value.text,
                );
              }
            },
          ),
          heightSpace20,
          PrimaryButton(
            text: 'SIGN_UP_HERE'.tr,
            color: AppTheme.colors.appSecondary,
            onPressed: () {
              Get.toNamed(RoutesPaths.signUpPage);
            },
          ),
          heightSpace20,
          Text(
            'orConnectWith'.tr,
            textAlign: TextAlign.center,
            style: AppTheme.style.medium.copyWith(
              fontSize: AppTheme.fontSize.f16,
              color: AppTheme.colors.appGrey,
            ),
          ),
          heightSpace15,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AppleSocialButton(onPressed: () {
              // controller.signInWithApple();
              // }),
              // widthSpace15,
              GmailSocialButton(onPressed: () {
                controller.signInWithGoogle();
              }),
            ],
          ),
          heightSpace15,
        ],
      ),
    );
  }
}
