import 'package:flutter/material.dart';

import 'colors.dart';

class InputTheme {
  static const TextSelectionThemeData textSelectionTheme = TextSelectionThemeData(
    selectionColor: ThemeColor.grey, // Text highlight color
    selectionHandleColor: ThemeColor.primaryColor, // Selection handle color
    cursorColor: ThemeColor.primaryColor, // Cursor color
  );

  static const TextStyle inputTextStyle = TextStyle(
    color: ThemeColor.primaryColor,
    fontSize: 16,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle hintTextStyle = TextStyle(
    color: ThemeColor.grey,
  );

  static InputDecoration getInputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintTextStyle,
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: ThemeColor.secondaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
    );
  }

  static Widget wrapWithTheme(Widget textField) {
    return TextSelectionTheme(
      data: textSelectionTheme,
      child: textField,
    );
  }
}
