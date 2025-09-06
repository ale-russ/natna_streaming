// reusable/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool? obscureText;

  final Widget? suffixIcon;
  final ValueChanged<bool>? onObscureTextToggle;
  final String title;

  const CustomTextField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText,
    this.suffixIcon,
    this.onObscureTextToggle,
    this.title = "",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 12),
          ),
        ),
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            obscureText: obscureText ?? false,
            style: TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 8,
              ),
              filled: true,
              fillColor: AppColors.textFieldColor.withOpacity(0.2),

              // Borders
              enabledBorder: _buildBorder(
                AppColors.borderColor.withOpacity(0.3),
                1.0,
              ),
              errorBorder: _buildBorder(AppColors.errorColor, 1.5),
              focusedBorder: _buildBorder(
                AppColors.borderColor.withOpacity(0.6),
                1.5,
              ),
              focusedErrorBorder: _buildBorder(AppColors.errorColor, 2.0),

              // Error styling
              errorMaxLines: 2,
              errorStyle: TextStyle(
                color: AppColors.errorColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),

              // Suffix icon for password fields
              suffixIcon: obscureText != null
                  ? IconButton(
                      icon: Icon(
                        obscureText!
                            ? FontAwesomeIcons.lock
                            : FontAwesomeIcons.unlock,
                        size: 10,
                      ),
                      onPressed: () => onObscureTextToggle?.call(!obscureText!),
                    )
                  : suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
