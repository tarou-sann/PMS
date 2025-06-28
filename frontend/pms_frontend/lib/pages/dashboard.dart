import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'currently_used_machines.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import 'productiontracking.dart';

class DashboardNav extends StatefulWidget {
  const DashboardNav({super.key});

  @override
  _DashboardNavState createState() => _DashboardNavState();
}

class _DashboardNavState extends State<DashboardNav> {
  String _username = ""; // Initialize with empty string
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService(); // Create API service instance

  // Add these new state variables for production data
  List<Map<String, dynamic>> _recentProduction = [];
    Map<String, dynamic> _productionStats = {
    'totalRecords': 0,
    'totalProduction': 0.0,
    'totalHectares': 0.0,
    'averageYield': 0.0,
    'thisMonthRecords': 0,
  };
  bool _isLoadingProduction = true;
  
  // Add recently used machines data
List<Map<String, dynamic>> _recentlyUsedMachines = [];
  bool _isLoadingRecentMachines = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProductionData();
    _loadRecentlyUsedMachines(); // Add this line
  }

  // Add this new method to load recently used machines
  Future<void> _loadRecentlyUsedMachines() async {
    setState(() {
      _isLoadingRecentMachines = true;
    });

    try {
      final recentMachines = await _apiService.getRecentlyUsedMachines();
      setState(() {
        _isLoadingRecentMachines = false;
        if (recentMachines != null) {
          _recentlyUsedMachines = recentMachines;
        } else {
          _recentlyUsedMachines = [];
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingRecentMachines = false;
        _recentlyUsedMachines = [];
      });
      print('Error loading recently used machines: $e');
    }
  }

  // Function to load the username from shared preferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? "";

    if (username.isEmpty) {
      // If not found in shared preferences, try to get from API
      try {
        final userInfo = await _apiService.getCurrentUser();
        if (userInfo != null && userInfo.containsKey('username')) {
          setState(() {
            _username = userInfo['username'];
          });

          // Save for future use
          await prefs.setString('username', _username);
        }
      } catch (e) {
        print('Error fetching user: $e');
      }
    } else {
      setState(() {
        _username = username;
      });
    }
  }

  // Add this new method to load production data
  Future<void> _loadProductionData() async {
    try {
      final records = await _apiService.getProductionRecords();
      if (records != null) {
        // Get current month for filtering
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;

        // Calculate statistics
        double totalProduction = 0.0;
        double totalHectares = 0.0;
        int thisMonthRecords = 0;
        List<Map<String, dynamic>> recentRecords = [];

        for (var record in records) {
          totalProduction += (record['quantity_harvested'] as num?)?.toDouble() ?? 0.0;
          totalHectares += (record['hectares'] as num?)?.toDouble() ?? 0.0;

          // Check if record is from this month
          final harvestDate = record['harvest_date'] as String?;
          if (harvestDate != null) {
            try {
              final date = DateTime.parse(harvestDate);
              if (date.month == currentMonth && date.year == currentYear) {
                thisMonthRecords++;
              }
            } catch (e) {
              // Skip invalid dates
            }
          }
        }

        // Get most recent 5 records for display
        records.sort((a, b) {
          final dateA = a['harvest_date'] as String? ?? '';
          final dateB = b['harvest_date'] as String? ?? '';
          return dateB.compareTo(dateA); // Most recent first
        });
        recentRecords = records.take(5).toList();

        setState(() {
          _recentProduction = recentRecords;
          _productionStats = {
            'totalRecords': records.length,
            'totalProduction': totalProduction,
            'totalHectares': totalHectares,
            'averageYield': totalHectares > 0 ? totalProduction / totalHectares : 0.0,
            'thisMonthRecords': thisMonthRecords,
          };
          _isLoadingProduction = false;
        });
      } else {
        setState(() {
          _isLoadingProduction = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProduction = false;
      });
    }
  }

  // Update refresh method
  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadProductionData(),
      _loadRecentlyUsedMachines(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: ThemeColor.secondaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Dashboard content
                _buildDashboardContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(builder: (context, constraints) {
      // Use a simpler layout approach
      return Column(
        children: [
          // Top row with Time and Production panels
          SizedBox(
            height: 300,
            child: Row(
              children: [
                // System Time panel
                Expanded(
                  flex: 1,
                  child: _buildTimePanel(),
                ),
                const SizedBox(width: 16),
                // Production Overview panel
                Expanded(
                  flex: 1,
                  child: _buildOverviewPanel(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Bottom row with Recently Used Machines panel (full width)
          SizedBox(
            height: 400,
            child: _buildMachinesPanel(),
          ),
        ],
      );
    });
  }

  Widget _buildTimePanel() {
    return Container(
      height: 280, // Fixed height
      decoration: BoxDecoration(
        color: ThemeColor.white2,
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
      padding: const EdgeInsets.all(16),
      child: Center(child: _SystemTimeDisplay()),
    );
  }

  // Wrap the production overview panel with GestureDetector
  Widget _buildOverviewPanel() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductionTrackingNav()),
        );
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: ThemeColor.white2,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          // Add subtle hover effect
          border: Border.all(
            color: ThemeColor.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Production Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ThemeColor.primaryColor.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _loadProductionData();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: ThemeColor.secondaryColor,
                        size: 20,
                      ),
                      tooltip: 'Refresh data',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoadingProduction)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                  ),
                ),
              )
            else if (_recentProduction.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No production data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Statistics Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Records',
                            '${_productionStats['totalRecords']}',
                            Icons.assignment,
                            ThemeColor.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'This Month',
                            '${_productionStats['thisMonthRecords']}',
                            Icons.calendar_today,
                            ThemeColor.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Avg Yield',
                            '${(_productionStats['averageYield'] as double).toStringAsFixed(1)} kg/ha',
                            Icons.trending_up,
                            ThemeColor.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Recent Records Header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent Records',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Recent Records List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentProduction.length,
                        itemBuilder: (context, index) {
                          final record = _recentProduction[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeColor.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: ThemeColor.grey.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.grass,
                                  color: ThemeColor.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    record['rice_variety_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: ThemeColor.primaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${record['hectares'] ?? 0} ha',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: ThemeColor.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${record['quantity_harvested'] ?? 0} kg',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: ThemeColor.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  record['harvest_date'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: ThemeColor.secondaryColor,
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
          ],
        ),
      ),
    );
  }

  // Add this helper method for building stat cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMachinesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.white2,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.history,
                    color: ThemeColor.secondaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Recently Used Machines',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.secondaryColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _loadRecentlyUsedMachines,
                icon: const Icon(
                  Icons.refresh,
                  color: ThemeColor.secondaryColor,
                  size: 18,
                ),
                tooltip: 'Refresh recent machines',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content area
          Expanded(
            child: _isLoadingRecentMachines
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                    ),
                  )
                : _recentlyUsedMachines.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No recently used machines',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Completed rentals will appear here',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: ThemeColor.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Machine',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColor.secondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Rentee',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColor.secondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Hours Used',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColor.secondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Returned',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColor.secondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Recently used machines list
                          Expanded(
                            child: ListView.builder(
                              itemCount: _recentlyUsedMachines.length > 5 ? 5 : _recentlyUsedMachines.length,
                              itemBuilder: (context, index) {
                                final machine = _recentlyUsedMachines[index];
                                
                                // Parse end date for display
                                String returnedDate = 'Unknown';
                                if (machine['end_date'] != null) {
                                  try {
                                    final endDate = DateTime.parse(machine['end_date']);
                                    final now = DateTime.now();
                                    final difference = now.difference(endDate).inDays;
                                    
                                    if (difference == 0) {
                                      returnedDate = 'Today';
                                    } else if (difference == 1) {
                                      returnedDate = 'Yesterday';
                                    } else if (difference < 7) {
                                      returnedDate = '${difference}d ago';
                                    } else {
                                      returnedDate = '${endDate.day}/${endDate.month}';
                                    }
                                  } catch (e) {
                                    returnedDate = 'Unknown';
                                  }
                                }
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: ThemeColor.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Machine Name
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _getMachineIcon(machine['machinery_type']),
                                              color: ThemeColor.primaryColor,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                machine['machinery_name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: ThemeColor.primaryColor,
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Rentee Name
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          machine['rentee_name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      // Hours Used
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              color: ThemeColor.green,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${machine['hours_used'] ?? 0}h',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: ThemeColor.green,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Returned Date
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          returnedDate,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Show "View All" link if there are more than 5 machines
                          if (_recentlyUsedMachines.length > 5)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to Machine History page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CurrentlyUsedMachines(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View All ${_recentlyUsedMachines.length} Recent Uses',
                                        style: const TextStyle(
                                          color: ThemeColor.primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: ThemeColor.primaryColor,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      );
  }

  // Helper method to get appropriate icon for machine type
  IconData _getMachineIcon(String? machineType) {
    switch (machineType?.toLowerCase()) {
      case 'tractor':
        return Icons.agriculture;
      case 'harvester':
        return Icons.grass;
      case 'planter':
        return Icons.eco;
      case 'sprayer':
        return Icons.opacity;
      default:
        return Icons.build;
    }
  }
}

class _DashboardPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardPanel({
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.white2,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SystemTimeDisplay extends StatefulWidget {
  @override
  _SystemTimeDisplayState createState() => _SystemTimeDisplayState();
}

class _SystemTimeDisplayState extends State<_SystemTimeDisplay> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'System Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColor.secondaryColor,
              ),
            ),
            Text(
              DateFormat('MMMM d, yyyy').format(_currentTime),
              style: const TextStyle(
                fontSize: 18,
                color: ThemeColor.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Center the large time display
        Center(
          child: Text(
            DateFormat('HH:mm').format(_currentTime),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
