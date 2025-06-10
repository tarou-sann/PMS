import 'package:flutter/material.dart';

import '../theme/colors.dart';

class CalendarTheme {
  static ThemeData get datePickerTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: ThemeColor.white2, // Header background
        onPrimary: ThemeColor.secondaryColor, // Header text color
        onSurface: ThemeColor.primaryColor, // Calendar text color
        surface: ThemeColor.white2, // Calendar background
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeColor.secondaryColor, // Button text color
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: ThemeColor.white2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Custom date picker wrapper method
  static Future<DateTime?> showCustomDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      helpText: helpText,
      builder: (context, child) {
        return Theme(
          data: datePickerTheme,
          child: child!,
        );
      },
    );
  }
}
