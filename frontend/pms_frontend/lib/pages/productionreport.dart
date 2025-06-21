import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import 'reports.dart';

class ProductionReport extends StatefulWidget {
  const ProductionReport({super.key});

  @override
  State<ProductionReport> createState() => _ProductionReportState();
}

class _ProductionReportState extends State<ProductionReport> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _productionRecords = [];
  List<Map<String, dynamic>> _riceVarieties = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProductionRecords(),
      _loadRiceVarieties(),
    ]);
  }

  Future<void> _loadProductionRecords() async {
    try {
      final records = await _apiService.getProductionRecords();
      if (records != null) {
        setState(() {
          _productionRecords = records;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading production records: $e';
      });
    }
  }

  Future<void> _loadRiceVarieties() async {
    try {
      final varieties = await _apiService.getRiceVarieties();
      if (varieties != null) {
        setState(() {
          _riceVarieties = varieties;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: $e';
      });
    }
  }

  // Print function for production report
  Future<void> _printReport() async {
    final pdf = pw.Document();
    final totalProduction = _productionRecords.fold<double>(
      0.0, 
      (sum, record) => sum + (record['quantity_harvested'] ?? 0.0)
    );
    final totalHectares = _productionRecords.fold<double>(
      0.0, 
      (sum, record) => sum + (record['hectares'] ?? 0.0)
    );
    final averageYield = totalHectares > 0 ? totalProduction / totalHectares : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Production Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Total Records', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_productionRecords.length.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Production', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${totalProduction.toStringAsFixed(2)} kg', style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Hectares', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${totalHectares.toStringAsFixed(2)} ha', style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Average Yield', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${averageYield.toStringAsFixed(2)} kg/ha', style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                },
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
                        child: pw.Text('Rice Variety', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Hectares', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Quantity (kg)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Yield/Hectare', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Harvest Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ..._productionRecords.map((record) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(record['id']?.toString() ?? 'N/A'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(record['rice_variety_name'] ?? 'Unknown'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${record['hectares'] ?? 0} ha'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${record['quantity_harvested'] ?? 0} kg'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${record['yield_per_hectare'] ?? 0} kg/ha'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(record['harvest_date'] ?? 'N/A'),
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
    // Calculate statistics
    final totalProduction = _productionRecords.fold<double>(
      0.0, 
      (sum, record) => sum + (record['quantity_harvested'] ?? 0.0)
    );
    final totalHectares = _productionRecords.fold<double>(
      0.0, 
      (sum, record) => sum + (record['hectares'] ?? 0.0)
    );
    final averageYield = totalHectares > 0 ? totalProduction / totalHectares : 0.0;
    final shatterCount = _riceVarieties.where((r) => r['quality_grade'] == 'Shatter').length;
    final nonShatterCount = _riceVarieties.where((r) => r['quality_grade'] == 'Non-Shattering').length;

    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer_Admin()
      ,
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const Text(
                        'Production Report',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      Row(
                        children: [
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
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                          ),
                        ],
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
                      _buildSummaryCard('Total Records', _productionRecords.length.toString(), ThemeColor.secondaryColor),
                      const SizedBox(width: 15),
                      _buildSummaryCard('Total Production', '${totalProduction.toStringAsFixed(1)} kg', ThemeColor.green),
                      const SizedBox(width: 15),
                      _buildSummaryCard('Total Hectares', '${totalHectares.toStringAsFixed(1)} ha', ThemeColor.primaryColor),
                      const SizedBox(width: 15),
                      _buildSummaryCard('Average Yield', '${averageYield.toStringAsFixed(1)} kg/ha', ThemeColor.red),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Production Records Table
                  const Text(
                    'Production Records',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Table Content
                  Expanded(
                    child: _productionRecords.isEmpty
                        ? const Center(
                            child: Text(
                              'No production records found',
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
                                        flex: 1,
                                        child: Text(
                                          'ID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Rice Variety',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Hectares',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Quantity (kg)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Yield/Hectare',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Harvest Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Production Records List
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _productionRecords.length,
                                    itemBuilder: (context, index) {
                                      final record = _productionRecords[index];
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
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    record['id'].toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: ThemeColor.primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Rice Variety
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.grass, color: ThemeColor.green, size: 20),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      record['rice_variety_name'] ?? 'Unknown',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: ThemeColor.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Hectares
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.landscape,
                                                      color: ThemeColor.secondaryColor, size: 16),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${record['hectares']} ha',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: ThemeColor.secondaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Quantity
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.scale, color: ThemeColor.grey, size: 16),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${record['quantity_harvested']} kg',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: ThemeColor.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Yield per Hectare
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ThemeColor.green.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${record['yield_per_hectare']} kg/ha',
                                                  style: const TextStyle(
                                                    color: ThemeColor.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                            // Harvest Date
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.calendar_today,
                                                      color: ThemeColor.secondaryColor, size: 16),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    record['harvest_date'] ?? 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: ThemeColor.secondaryColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
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
          color: ThemeColor.white2,
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColor.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}