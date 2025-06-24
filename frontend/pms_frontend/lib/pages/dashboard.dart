import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';

class DashboardNav extends StatefulWidget {
  const DashboardNav({super.key});

  @override
  _DashboardNavState createState() => _DashboardNavState();
}

class _DashboardNavState extends State<DashboardNav> {
  String _username = ""; // Initialize with empty string
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService(); // Create API service instance

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Load username when widget initializes
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 0.95,
                  child: _buildDashboardContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // System Time panel
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: _buildTimePanel(),
            ),

            // Production Overview panel
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: _buildOverviewPanel(),
            ),

            // Recently Used Machines panel (spans full width)
            StaggeredGridTile.fit(
              crossAxisCellCount: 2,
              child: _buildMachinesPanel(),
            ),
          ],
        ),
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

  Widget _buildOverviewPanel() {
    return Container(
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
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColor.secondaryColor,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  'No production data available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachinesPanel() {
    // For machines panel
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently Used Machines',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColor.secondaryColor,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            width: double.infinity,
            // This would be replaced with actual machine data
            child: Center(
              child: Text(
                'No recent machine usage data',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
