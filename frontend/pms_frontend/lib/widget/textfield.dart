import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/inputtheme.dart';

class ThemedTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final double? height;
  final double? width;

  const ThemedTextFormField(
      {super.key,
      this.controller,
      this.validator,
      this.hintText,
      this.obscureText = false,
      this.readOnly = false,
      this.onTap,
      this.suffixIcon,
      this.maxLines = 1,
      this.keyboardType,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    final textFormField = TextSelectionTheme(
      data: InputTheme.textSelectionTheme,
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: keyboardType,
        cursorColor: ThemeColor.primaryColor,
        style: InputTheme.inputTextStyle,
        decoration: InputTheme.getInputDecoration(hintText).copyWith(
          suffixIcon: suffixIcon,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 10,
          ),
        ),
      ),
    );

    if (height != null) {
      return SizedBox(
        height: height,
        width: width,
        child: textFormField,
      );
    }

    return textFormField;
  }
}
