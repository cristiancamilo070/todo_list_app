import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/drawer/items/item.dart';
import 'package:todo_list_app/presentation/home/controllers/home_controller.dart';

class DrawerItems extends GetView<HomeController> {
  const DrawerItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.appPrimary,
            borderRadius: BorderRadius.circular(10.0.r),
          ),
          child: HomeDrawerItem(
            title: "LOGOUT".tr,
            padding: false,
            icon: FontAwesomeIcons.rightFromBracket,
            onTap: () async {
              await controller.logOut();
            },
          ),
        ).paddingOnly(left: 30.w),
      ],
    );
  }
}
