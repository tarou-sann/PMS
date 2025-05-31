// Create new file: frontend/pms_frontend/lib/pages/production_report.dart
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
  List<Map<String, dynamic>> _riceVarieties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiceVarieties();
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
      });
    }
  }

  // Print function for production report
  Future<void> _printReport() async {
    final pdf = pw.Document();
    final shatterCount = _riceVarieties.where((r) => r['quality_grade'] == 'Shatter').length;
    final nonShatterCount = _riceVarieties.where((r) => r['quality_grade'] == 'Non-Shattering').length;

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
              
              // Quality Grade Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Total Varieties', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_riceVarieties.length.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Shatter', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(shatterCount.toString(), style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Non-Shattering', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(nonShatterCount.toString(), style: pw.TextStyle(fontSize: 18)),
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
                        child: pw.Text('Variety Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Quality Grade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Expiration Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ..._riceVarieties.map((rice) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(rice['id']?.toString() ?? 'N/A'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(rice['variety_name'] ?? 'Unknown'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(rice['quality_grade'] ?? 'N/A'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(rice['expiration_date'] ?? 'N/A'),
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
    final premiumGrade = _riceVarieties.where((r) => r['quality_grade'] == 'Shatter').length;
    final gradeA = _riceVarieties.where((r) => r['quality_grade'] == 'Non-Shattering').length;

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
                    'Production Report',
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
                  
                  // Quality Grade Summary
                  Row(
                    children: [
                      _buildQualityCard('Shatter', premiumGrade.toString(), Colors.purple),
                      const SizedBox(width: 15),
                      _buildQualityCard('Non-Shattering', gradeA.toString(), Colors.green),
                      const SizedBox(width: 15)
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Rice Varieties Details',
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
                        itemCount: _riceVarieties.length,
                        itemBuilder: (context, index) {
                          final rice = _riceVarieties[index];
                          return Card(
                            child: ListTile(
                              title: Text(rice['variety_name'] ?? 'Unknown'),
                              subtitle: Text('Expiration: ${rice['expiration_date'] ?? 'N/A'}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getQualityColor(rice['quality_grade']),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  rice['quality_grade'] ?? 'N/A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  Widget _buildQualityCard(String title, String value, Color color) {
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(String? grade) {
    switch (grade) {
      case 'Shatter':
        return Colors.purple;
      case 'Non-Shattering':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}