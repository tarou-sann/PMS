import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import 'reports.dart';
import '../utils/formatters.dart';

class MachineStatusReport extends StatefulWidget {
  const MachineStatusReport({super.key});

  @override
  State<MachineStatusReport> createState() => _MachineStatusReportState();
}

class _MachineStatusReportState extends State<MachineStatusReport> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _machinery = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMachinery();
  }

  Future<void> _loadMachinery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final machinery = await _apiService.getMachinery();
      setState(() {
        _isLoading = false;
        if (machinery != null) {
          _machinery = machinery;
        } else {
          _errorMessage = 'Failed to load machinery data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading machinery: $e';
      });
    }
  }

  // Print function for machine status report
  Future<void> _printReport() async {
    final pdf = pw.Document();
    final activeMachines = _machinery.where((m) => m['is_active'] == true).length;
    final inactiveMachines = _machinery.where((m) => m['is_active'] == false).length;
    final mobileMachines = _machinery.where((m) => m['is_mobile'] == true).length;
    final staticMachines = _machinery.where((m) => m['is_mobile'] == false).length;
    final repairsNeeded = _machinery.where((m) => m['repairs_needed'] == true).length;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Machine Status Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Total Machines', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_machinery.length.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Active', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(activeMachines.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Inactive', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(inactiveMachines.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Mobile', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(mobileMachines.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Static', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(staticMachines.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Repairs Needed', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(repairsNeeded.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Machine Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Mobile?', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Can Harvest?', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Hour Meter', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Repairs Needed', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ..._machinery.map((machine) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(Formatters.formatId(machine['id'])),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(machine['machine_name'] ?? 'Unknown'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(machine['is_mobile'] ? 'Yes' : 'No'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(machine['is_active'] ? 'Yes' : 'No'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${machine['hour_meter'] ?? 0} hrs'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text((machine['repairs_needed'] ?? false) ? 'Yes' : 'No'),
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

  @override
  Widget build(BuildContext context) {
    final activeMachines = _machinery.where((m) => m['is_active'] == true).length;
    final inactiveMachines = _machinery.where((m) => m['is_active'] == false).length;
    final mobileMachines = _machinery.where((m) => m['is_mobile'] == true).length;
    final staticMachines = _machinery.where((m) => m['is_mobile'] == false).length;
    final repairsNeeded = _machinery.where((m) => m['repairs_needed'] == true).length;

    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 30,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Machine Status Report',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                      ),
                      // Print button
                      ElevatedButton.icon(
                        onPressed: _printReport,
                        icon: const Icon(Icons.print, color: ThemeColor.white),
                        label: const Text(
                          'Print Report',
                          style: TextStyle(color: ThemeColor.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColor.secondaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Refresh button
                      IconButton(
                        onPressed: _loadMachinery,
                        icon: const Icon(
                          Icons.refresh,
                          color: ThemeColor.secondaryColor,
                        ),
                        tooltip: 'Refresh data',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeColor.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: ThemeColor.red),
                        ),
                      ),
                    ),

                  // Summary Cards
                  Row(
                    children: [
                      _buildSummaryCard('Total Machines', _machinery.length.toString(), ThemeColor.secondaryColor),
                      const SizedBox(width: 15),
                      _buildSummaryCard('Active', activeMachines.toString(), ThemeColor.green),
                      const SizedBox(width: 15),
                      _buildSummaryCard('Mobile', mobileMachines.toString(), ThemeColor.primaryColor),
                      const SizedBox(width: 15),
                      _buildSummaryCard('Repairs Needed', repairsNeeded.toString(), ThemeColor.red),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Machine Details Table
                  const Text(
                    'Machine Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Table Content
                  Expanded(
                    child: _machinery.isEmpty
                        ? const Center(
                            child: Text(
                              'No machinery found',
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeColor.grey,
                              ),
                            ),
                          )
                        : Container(
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
                                // Table Header
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
                                        flex: 1,
                                        child: Text(
                                          'ID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Machine Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Mobile?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Can Harvest?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Hour Meter',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Repairs Needed',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Table Body
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _machinery.length,
                                    itemBuilder: (context, index) {
                                      final machine = _machinery[index];
                                      return Container(
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
                                            // ID
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                Formatters.formatId(machine['id']),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: ThemeColor.primaryColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),

                                            // Machine Name
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.agriculture,
                                                      color: ThemeColor.primaryColor, size: 20),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      machine['machine_name'] ?? 'Unknown',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: ThemeColor.primaryColor,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Mobile - styled badge
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: machine['is_mobile']
                                                      ? ThemeColor.primaryColor.withOpacity(0.1)
                                                      : ThemeColor.secondaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  machine['is_mobile'] ? 'Yes' : 'No',
                                                  style: TextStyle(
                                                    color: machine['is_mobile']
                                                        ? ThemeColor.primaryColor
                                                        : ThemeColor.secondaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                            // Can Harvest - styled badge
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: machine['is_active']
                                                      ? ThemeColor.green.withOpacity(0.1)
                                                      : ThemeColor.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  machine['is_active'] ? 'Yes' : 'No',
                                                  style: TextStyle(
                                                    color: machine['is_active'] 
                                                        ? ThemeColor.green 
                                                        : ThemeColor.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                            // Hour Meter
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.schedule,
                                                      color: ThemeColor.secondaryColor, size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${machine['hour_meter'] ?? 0} hrs',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: ThemeColor.secondaryColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Repairs Needed - styled badge
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: (machine['repairs_needed'] ?? false)
                                                      ? ThemeColor.red.withOpacity(0.1)
                                                      : ThemeColor.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  (machine['repairs_needed'] ?? false) ? 'Yes' : 'No',
                                                  style: TextStyle(
                                                    color: (machine['repairs_needed'] ?? false)
                                                        ? ThemeColor.red
                                                        : ThemeColor.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: ThemeColor.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}