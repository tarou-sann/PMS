import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/about.dart';
import '../pages/dashboard.dart';
import '../pages/forecasting.dart';
import '../pages/help.dart';
import '../pages/machinerymanagement.dart';
import '../pages/maintenance.dart';
import '../pages/productiontracking.dart';
import '../pages/register.dart';
import '../pages/reports.dart';
import '../pages/search.dart';
import '../pages/signup.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../theme/colors.dart';

class EndDrawer extends StatefulWidget {
  const EndDrawer({super.key});

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  String _username = "Loading...";
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      // Get username from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('username') ?? "";
      
      // Get current user info from API
      final userInfo = await ApiService().getCurrentUser();
      
      if (userInfo != null) {
        username = userInfo['username'] ?? username;
        final isAdmin = userInfo['is_admin'] ?? false;
        
        // Save username if not already saved
        if (username.isNotEmpty) {
          await prefs.setString('username', username);
        }
        
        if (mounted) {
          setState(() {
            _username = username.isNotEmpty ? username : "User";
            _isAdmin = isAdmin;
            _isLoading = false;
          });
        }
      } else {
        // Fallback to stored username if API fails
        if (mounted) {
          setState(() {
            _username = username.isNotEmpty ? username : "User";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
      if (mounted) {
        setState(() {
          _username = "User";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAdmin ? _buildAdminDrawer() : _buildEmployeeDrawer();
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: ThemeColor.white2,
      width: 400,
      child: Column(
        children: [
          // User Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: ThemeColor.secondaryColor.withOpacity(0.26),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: ThemeColor.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: ThemeColor.white2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_username!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.secondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 18,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items (keep existing menu items)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildMenuTile(
                  icon: Symbols.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.app_registration,
                  title: 'Registration',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterBase(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.agriculture,
                  title: 'Machinery Management',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MachineryManagementNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.inventory_2,
                  title: 'Production Tracking',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductionTrackingNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.trending_up,
                  title: 'Forecasting',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForecastingPage(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.search,
                  title: 'Search',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.bar_chart,
                  title: 'Reports',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.build,
                  title: 'Maintenance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MaintenanceNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.help,
                  title: 'Help',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpModule(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.info,
                  title: 'About',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUs(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button at Bottom
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.white2,
                  foregroundColor: ThemeColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: ThemeColor.grey, width: 1),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDrawer() {
    return Drawer(
      backgroundColor: ThemeColor.white2,
      width: 400,
      child: Column(
        children: [
          // User Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: ThemeColor.secondaryColor.withOpacity(0.26),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: ThemeColor.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        color: ThemeColor.white2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_username!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.secondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Employee',
                        style: TextStyle(
                          fontSize: 18,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items (employee menu items)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildMenuTile(
                  icon: Symbols.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.agriculture,
                  title: 'Machinery Management',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MachineryManagementNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.inventory_2,
                  title: 'Production Tracking',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductionTrackingNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.trending_up,
                  title: 'Forecasting',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForecastingPage(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.search,
                  title: 'Search',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.bar_chart,
                  title: 'Reports',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsNav(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.help,
                  title: 'Help',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpModule(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Symbols.info,
                  title: 'About',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUs(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button at Bottom
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.white2,
                  foregroundColor: ThemeColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: ThemeColor.grey, width: 1),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 28,
          color: ThemeColor.primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, color: ThemeColor.primaryColor, fontWeight: FontWeight.w400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: ThemeColor.grey.withOpacity(0.1),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            height: 350,
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: const BoxDecoration(
              color: ThemeColor.white2,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Confirm Logout',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26, color: ThemeColor.primaryColor),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(fontSize: 24, color: ThemeColor.primaryColor),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: ThemeColor.primaryColor, fontSize: 24),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    final apiService = ApiService();
                    await apiService.logout();
                    UserService().clearCache();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignUpForm(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: ThemeColor.red, fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}