import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/core/controllers/main_controller.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/drawer/items/items.dart';
import 'package:todo_list_app/presentation/home/controllers/home_controller.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (_) {
      return SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25.h, bottom: 25.h, left: 25.w),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: FaIcon(
                      FontAwesomeIcons.solidNoteSticky,
                      color: AppTheme.colors.white,
                      size: 90.r,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: Text(
                          Get.find<HomeController>().userInfo.value?.email ??
                              'WELCOME'.tr,
                          style: AppTheme.style.bold.copyWith(
                            fontSize: AppTheme.fontSize.f22,
                            color: AppTheme.colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                heightSpace16,
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30.w, bottom: 25.h),
                      child: Text(
                        Get.find<HomeController>().userInfo.value?.name ??
                            'WELCOME'.tr,
                        textAlign: TextAlign.end,
                        style: AppTheme.style.bold.copyWith(
                          fontSize: AppTheme.fontSize.f18,
                          color: AppTheme.colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const DrawerItems(),
              ],
            ),
          ),
        ],
      ));
    });
  }
}
