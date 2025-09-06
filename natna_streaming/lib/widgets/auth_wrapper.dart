import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import 'gradient_scaffold.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        automaticallyImplyLeading: false,
        leadingWidth: 50, // Reduce the width of the leading area
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              FontAwesomeIcons.chevronLeft,
              size: 15, // Reduce icon size for consistency
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 72),
          height: 500,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
