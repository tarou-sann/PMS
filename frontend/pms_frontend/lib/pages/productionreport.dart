// Create new file: frontend/pms_frontend/lib/pages/production_report.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';

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
                  const Text(
                    'Production Report',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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