import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/core/themes/app_theme.dart';
import 'package:todo_list_app/core/widgets/buttons/base_social_button.dart';

class GmailSocialButton extends BaseSocialButton {
  const GmailSocialButton({
    Key? key,
    super.size = 30,
    required super.onPressed,
  }) : super(key: key, assetImage: googleLogo);
}
