// Create new file: frontend/pms_frontend/lib/pages/machine_status_report.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';

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
      endDrawer: const EndDraw(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Machine Status Report',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                              title: Text(machine['name'] ?? 'Unknown'),
                              subtitle: Text('${machine['type']} - ${machine['model']}'),
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