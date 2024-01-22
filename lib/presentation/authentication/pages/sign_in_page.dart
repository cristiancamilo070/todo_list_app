import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        heightSpace30,
        AppTextField(
          inputsParams: AppInputParameters(
            controller: controller.emailController,
            hintText: 'EMAIL'.tr,
            inputType: AppInputType.email,
          ),
        ).paddingSymmetric(horizontal: 16.w),
        heightSpace30,
        AppTextField(
          inputsParams: AppInputParameters(
            controller: controller.passwordController,
            hintText: 'PASSWORD'.tr,
            inputType: AppInputType.password,
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
