import 'package:flutter/material.dart';

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

class EndDraw extends StatelessWidget {
  const EndDraw({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 24,
      color: Colors.black,
    );

    return Drawer(
      backgroundColor: ThemeColor.white2,
      width: 400,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildPaddedListTile(
            title: 'Home',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardNav(),
                ),
              );
              print("moving to navigation");
            },
          ),
          _buildPaddedListTile(
            title: 'Registration',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterBase(),
                ),
              );
              print("moving to registration");
            },
          ),
          _buildPaddedListTile(
            title: 'Machine Management',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MachineryManagementNav(),
                ),
              );
              print("moving to machinerymanagement");
            },
          ),
          _buildPaddedListTile(
            title: 'Production Tracking',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductionTrackingNav(),
                ),
              );
              print("moving to machinerymanagement");
            },
          ),
          _buildPaddedListTile(
            title: 'Forecasting',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForecastingPage(),
                ),
              );
              print("moving to machinerymanagement");
            },
          ),
          _buildPaddedListTile(
            title: 'Search',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchNav(),
                ),
              );
              print("moving to search");
            },
          ),
          _buildPaddedListTile(
            title: 'Reports',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportsNav(),
                ),
              );
              print("moving to reports");
            },
          ),
          _buildPaddedListTile(
            title: 'Maintenance',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceNav(),
                ),
              );
              print("moving to maintenance");
            },
          ),
          _buildPaddedListTile(
            title: 'Help',
            style: listTileTextStyle,
          ),
          _buildPaddedListTile(
            title: 'About',
            style: listTileTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutUs(),
                ),
              );
              print("moving to about");
            },
          ),
          _buildPaddedListTile(
            title: 'Logout',
            style: listTileTextStyle,
            onTap: () {
              // Show confirmation dialog
              showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaddedListTile({required String title, required TextStyle style, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: style),
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
            ),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Confirm Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: ThemeColor.primaryColor, fontSize: 24),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Close the dialog
                    Navigator.of(dialogContext).pop();

                    // Log out user - clear tokens and stored data
                    final apiService = ApiService();
                    await apiService.logout();

                    // Clear username cache
                    UserService().clearCache();

                    // Navigate to sign up screen and clear navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignUpForm(),
                      ),
                      (Route<dynamic> route) => false, // Remove all previous routes
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
