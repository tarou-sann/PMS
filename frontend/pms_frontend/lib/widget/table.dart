import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ReusableTable extends StatelessWidget {
  final List<TableColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool isLoading;
  final String? errorMessage;
  final String emptyMessage;
  final Function(Map<String, dynamic>)? onRowTap;
  final List<Widget> Function(Map<String, dynamic>)? rowActions;

  const ReusableTable({
    super.key,
    required this.columns,
    required this.data,
    this.isLoading = false,
    this.errorMessage,
    this.emptyMessage = 'No data available',
    this.onRowTap,
    this.rowActions,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: ThemeColor.red),
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            color: ThemeColor.grey,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColor.secondaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: columns.map((column) {
                return Expanded(
                  flex: column.flex,
                  child: Text(
                    column.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.secondaryColor,
                      fontSize: 14,
                    ),
                    textAlign: column.alignment,
                  ),
                );
              }).toList(),
            ),
          ),

          // Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final row = data[index];
                return InkWell(
                  onTap: onRowTap != null ? () => onRowTap!(row) : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ThemeColor.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Data columns
                        ...columns.where((col) => !col.isAction).map((column) {
                          return Expanded(
                            flex: column.flex,
                            child: _buildCell(row, column),
                          );
                        }).toList(),
                        
                        // Action column (if exists)
                        if (columns.any((col) => col.isAction) && rowActions != null)
                          Expanded(
                            flex: columns.firstWhere((col) => col.isAction).flex,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: rowActions!(row),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(Map<String, dynamic> row, TableColumn column) {
    final value = row[column.dataKey];
    
    if (column.customBuilder != null) {
      return column.customBuilder!(value, row);
    }

    return Text(
      value?.toString() ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: column.textColor ?? ThemeColor.primaryColor,
        fontSize: 12,
      ),
      textAlign: column.alignment,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TableColumn {
  final String title;
  final String dataKey;
  final int flex;
  final TextAlign alignment;
  final Color? textColor;
  final bool isAction;
  final Widget Function(dynamic value, Map<String, dynamic> row)? customBuilder;

  const TableColumn({
    required this.title,
    required this.dataKey,
    this.flex = 1,
    this.alignment = TextAlign.left,
    this.textColor,
    this.isAction = false,
    this.customBuilder,
  });
}