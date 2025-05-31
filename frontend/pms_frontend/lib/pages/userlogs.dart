// Update: frontend/pms_frontend/lib/pages/userlogs.dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/user_activity_service.dart';
import 'reports.dart';

class UserLogs extends StatefulWidget {
  const UserLogs({super.key});

  @override
  State<UserLogs> createState() => _UserLogsState();
}

class _UserLogsState extends State<UserLogs> {
  final UserActivityService _activityService = UserActivityService();
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserActivities();
  }

  Future<void> _loadUserActivities() async {
    try {
      final activities = await _activityService.getUserActivities();
      if (activities != null) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No activity data available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading activities: $e';
        _isLoading = false;
      });
    }
  }

  // Print function for user logs
  Future<void> _printReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'User Activity Logs',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              pw.Text(
                'Total Activities: ${_activities.length}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              
              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('User', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Action', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Target', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  // Data rows
                  ..._activities.map((activity) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(activity['username'] ?? 'Unknown', style: pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(activity['action'] ?? 'Unknown', style: pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(activity['details'] ?? 'No details', style: pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(activity['target'] ?? '-', style: pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(_formatTimestamp(activity['timestamp'] ?? ''), style: pw.TextStyle(fontSize: 9)),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }


  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'register':
      case 'add':
        return Colors.green;
      case 'update':
      case 'edit':
      case 'modify':
        return Colors.blue;
      case 'delete':
      case 'remove':
        return Colors.red;
      case 'login':
      case 'logout':
        return Colors.orange;
      case 'view':
      case 'search':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Icon _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'register':
      case 'add':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'update':
      case 'edit':
      case 'modify':
        return const Icon(Icons.edit, color: Colors.blue);
      case 'delete':
      case 'remove':
        return const Icon(Icons.delete, color: Colors.red);
      case 'login':
        return const Icon(Icons.login, color: Colors.orange);
      case 'logout':
        return const Icon(Icons.logout, color: Colors.orange);
      case 'view':
        return const Icon(Icons.visibility, color: Colors.purple);
      case 'search':
        return const Icon(Icons.search, color: Colors.purple);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportsNav(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: ThemeColor.secondaryColor,
                            size: 30,
                          ),
                        ),
                      const Text(
                        'User Activity Logs',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          // Print button
                          ElevatedButton.icon(
                            onPressed: _printReport,
                            icon: const Icon(Icons.print, color: Colors.white),
                            label: const Text('Print Report', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColor.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _loadUserActivities,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else if (_activities.isEmpty)
                    const Center(
                      child: Text(
                        'No user activities recorded yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
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
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'User',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Action',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Target',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Time',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.secondaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Activity List
                            Expanded(
                              child: ListView.builder(
                                itemCount: _activities.length,
                                itemBuilder: (context, index) {
                                  final activity = _activities[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // User
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: ThemeColor.secondaryColor,
                                                child: Text(
                                                  (activity['username'] ?? 'U')[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  activity['username'] ?? 'Unknown',
                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Action
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              _getActionIcon(activity['action'] ?? ''),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getActionColor(activity['action'] ?? '')
                                                        .withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    activity['action'] ?? 'Unknown',
                                                    style: TextStyle(
                                                      color: _getActionColor(activity['action'] ?? ''),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Details
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            activity['details'] ?? 'No details',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        
                                        // Target
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            activity['target'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        
                                        // Time
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _formatTimestamp(activity['timestamp'] ?? ''),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}