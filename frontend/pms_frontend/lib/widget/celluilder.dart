import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';

class TableCellBuilders {
  // ID cell with formatting
  static Widget idCell(dynamic value, Map<String, dynamic> row) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          Formatters.formatId(value),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Cell with icon and text
  static Widget iconTextCell(dynamic value, Map<String, dynamic> row, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value?.toString() ?? 'Unknown',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: iconColor,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Status chip cell
  static Widget statusChipCell(dynamic value, Map<String, dynamic> row, {Color? activeColor, Color? inactiveColor}) {
    final isActive = value == true || value == 'Yes' || value == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? (activeColor ?? ThemeColor.green).withOpacity(0.2)
            : (inactiveColor ?? ThemeColor.red).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Yes' : 'No',
        style: TextStyle(
          color: isActive ? (activeColor ?? ThemeColor.green) : (inactiveColor ?? ThemeColor.red),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Yield badge cell
  static Widget yieldBadgeCell(dynamic value, Map<String, dynamic> row) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ThemeColor.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value kg/ha',
        style: const TextStyle(
          color: ThemeColor.green,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Date cell with icon
  static Widget dateCell(dynamic value, Map<String, dynamic> row) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: ThemeColor.secondaryColor, size: 16),
        const SizedBox(width: 4),
        Text(
          value?.toString() ?? 'N/A',
          style: const TextStyle(
            fontSize: 12,
            color: ThemeColor.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Quality grade badge
  static Widget qualityGradeCell(dynamic value, Map<String, dynamic> row) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColor.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        value?.toString() ?? '',
        style: const TextStyle(
          color: ThemeColor.secondaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}