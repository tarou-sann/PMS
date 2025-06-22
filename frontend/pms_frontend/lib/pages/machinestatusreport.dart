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
    try {
      final machinery = await _apiService.getMachinery();
      if (machinery != null) {
        setState(() {
          _machinery = machinery;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading machinery: $e';
        _isLoading = false;
      });
    }
  }

  // Print function for machine status report
  Future<void> _printReport() async {
    final pdf = pw.Document();
    final activeMachines = _machinery.where((m) => m['is_active'] == true).length;
    final inactiveMachines = _machinery.where((m) => m['is_active'] == false).length;
    final mobileMachines = _machinery.where((m) => m['is_mobile'] == true).length;

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
                        child: pw.Text('Mobile', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                        child: pw.Text(machine['is_active'] ? 'Active' : 'Inactive'),
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

    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Machine Status Report',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  // Print button
                  ElevatedButton.icon(
                    onPressed: _printReport,
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: const Text('Print Report', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Summary Cards
                  Row(
                    children: [
                      _buildSummaryCard('Total Machines', _machinery.length.toString(), Colors.blue),
                      const SizedBox(width: 20),
                      _buildSummaryCard('Active', activeMachines.toString(), Colors.green),
                      const SizedBox(width: 20),
                      _buildSummaryCard('Inactive', inactiveMachines.toString(), Colors.red),
                      const SizedBox(width: 20),
                      _buildSummaryCard('Mobile', mobileMachines.toString(), Colors.orange),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Machine List
                  const Text(
                    'Machine Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _machinery.length,
                        itemBuilder: (context, index) {
                          final machine = _machinery[index];
                          return Card(
                            child: ListTile(
                              title: Text(machine['machine_name'] ?? 'Unknown'),
                              subtitle: Text('ID: ${machine['id'] ?? 'N/A'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(machine['is_active'] ? 'Active' : 'Inactive'),
                                    backgroundColor: machine['is_active'] ? Colors.green : Colors.red,
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(machine['is_mobile'] ? 'Mobile' : 'Static'),
                                    backgroundColor: machine['is_mobile'] ? Colors.orange : Colors.purple,
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}