import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required Color textColor,
  }) {
    // final snackBar = SnackBar(
    //   backgroundColor: AppColors.background,
    //   behavior: SnackBarBehavior.floating,
    //   elevation: 0,
    //   content: Text(message, style: TextStyle(color: textColor)),
    //   duration: const Duration(seconds: 3),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.background,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        content: Text(message, style: TextStyle(color: textColor)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
