import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import 'repair.dart';

class RepairstatusNav extends StatefulWidget {
  const RepairstatusNav({super.key});

  @override
  State<RepairstatusNav> createState() => _RepairstatusNavState();
}

class _RepairstatusNavState extends State<RepairstatusNav> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _repairs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repairs = await _apiService.getRepairs();
      setState(() {
        _isLoading = false;
        if (repairs != null) {
          _repairs = repairs;
        } else {
          _errorMessage = 'Failed to load repair data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  String _getStatusColor(String status) {
    switch(status) {
      case 'pending':
        return '#FFA726'; // Orange
      case 'in_progress':
        return '#2196F3'; // Blue
      case 'completed':
        return '#4CAF50'; // Green
      default:
        return '#757575'; // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle tableHeaderStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ThemeColor.secondaryColor,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Back arrow and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RepairNav(),
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
                  "Repair Status",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Refresh button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _loadRepairs,
                icon: const Icon(
                  Icons.refresh,
                  color: ThemeColor.secondaryColor,
                ),
                tooltip: 'Refresh data',
              ),
            ),
            
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                border: Border.all(color: ThemeColor.primaryColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text('ID', style: tableHeaderStyle),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Machine', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Issue', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Parts', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Status', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Urgent', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Actions', style: tableHeaderStyle),
                  ),
                ],
              ),
            ),
            
            // Table content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.secondaryColor,
                        ),
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _repairs.isEmpty
                          ? const Center(
                              child: Text('No repair orders found'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ThemeColor.primaryColor,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: ListView.builder(
                                itemCount: _repairs.length,
                                itemBuilder: (context, index) {
                                  final repair = _repairs[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.1),
                                      border: index < _repairs.length - 1
                                          ? const Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        children: [
                                          // ID
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                              ),
                                              child: Text(
                                                repair['id'].toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Machine Name
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              repair['machinery_name'] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          // Issue
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              repair['issue_description'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          // Parts (notes field)
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              repair['notes'] ?? 'Not specified',
                                            ),
                                          ),
                                          // Status
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(int.parse(
                                                  _getStatusColor(repair['status']).substring(1, 7),
                                                  radix: 16,
                                                ) | 0xFF000000).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                repair['status'].toString().toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color(int.parse(
                                                    _getStatusColor(repair['status']).substring(1, 7),
                                                    radix: 16,
                                                  ) | 0xFF000000),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Urgent
                                          Expanded(
                                            flex: 1,
                                            child: repair['is_urgent'] 
                                              ? const Icon(Icons.warning, color: Colors.red)
                                              : const SizedBox(),
                                          ),
                                          // Actions
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: ThemeColor.secondaryColor,
                                                  ),
                                                  onPressed: () {
                                                    // Edit action will be implemented later
                                                  },
                                                  tooltip: 'Edit',
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.done_all,
                                                    color: Colors.green,
                                                  ),
                                                  onPressed: () async {
                                                    // Mark as completed
                                                    if (repair['status'] != 'completed') {
                                                      await _apiService.updateRepair(
                                                        repair['id'], 
                                                        {'status': 'completed'}
                                                      );
                                                      _loadRepairs();
                                                    }
                                                  },
                                                  tooltip: 'Mark as Complete',
                                                ),
                                              ],
                                            ),
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
}