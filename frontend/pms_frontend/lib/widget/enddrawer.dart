import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../pages/dashboard.dart';
import '../pages/machinerymanagement.dart';
import '../pages/maintenance.dart';
import '../pages/register.dart';
import '../pages/reports.dart';
import '../pages/search.dart';
import '../pages/signup.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../theme/colors.dart';
import '../pages/about.dart';
import '../pages/productiontracking.dart';
import '../pages/forecasting.dart';

class EndDrawer_Admin extends StatelessWidget {
  const EndDrawer_Admin({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: ThemeColor.white2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, {username}!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 18,
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu Items
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
                  icon: Symbols.precision_manufacturing,
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
                  onTap: () {},
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
                  showLogoutConfirmationDialog(context);
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
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
          style: const TextStyle(
            fontSize: 20,
            color: ThemeColor.primaryColor,
            fontWeight: FontWeight.w400
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: ThemeColor.grey.withOpacity(0.1),
      ),
    );
  }

  void showLogoutConfirmationDialog(BuildContext context) {
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: ThemeColor.primaryColor
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 24,
                  color: ThemeColor.primaryColor
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: ThemeColor.primaryColor,
                      fontSize: 24
                    ),
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
                    style: TextStyle(
                      color: ThemeColor.red,
                      fontSize: 24
                    ),
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


class EndDrawer_Employee extends StatelessWidget {
  const EndDrawer_Employee({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: const Center(
                    child: Text(
                      'E',
                      style: TextStyle(
                        color: ThemeColor.white2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, {user}!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    Text(
                      'Employee',
                      style: TextStyle(
                        fontSize: 18,
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu Items
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
                  icon: Symbols.precision_manufacturing,
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
                  onTap: () {},
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
                  showLogoutConfirmationDialog(context);
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
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
          style: const TextStyle(
            fontSize: 20,
            color: ThemeColor.primaryColor,
            fontWeight: FontWeight.w400
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: ThemeColor.grey.withOpacity(0.1),
      ),
    );
  }
  void showLogoutConfirmationDialog(BuildContext context) {
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: ThemeColor.primaryColor
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 24,
                  color: ThemeColor.primaryColor
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: ThemeColor.primaryColor,
                      fontSize: 24
                    ),
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
                    style: TextStyle(
                      color: ThemeColor.red,
                      fontSize: 24
                    ),
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
