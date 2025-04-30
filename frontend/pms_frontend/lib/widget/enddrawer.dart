import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../pages/register.dart';
import '../pages/machinerymanagement.dart';
import '../pages/reports.dart';
import '../pages/search.dart';
import '../pages/maintenance.dart';
import '../pages/dashboard.dart';
import '../pages/signup.dart';
import '../services/api_service.dart';
import '../services/user_service.dart'; // Add this import

class EndDraw extends StatelessWidget {
  const EndDraw({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardNav(),
                ),
              );
              print("moving to registration");
            },
            title: const Text('Home', style: listTileTextStyle),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterBase(),
                ),
              );
              print("moving to registration");
            },
            title: const Text('Registration', style: listTileTextStyle),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MachineryManagementNav(),
                ),
              );
              print("moving to machinerymanagement");
            },
            title: const Text('Machine Management', style: listTileTextStyle),
          ),
          const ListTile(
            title: Text('Production Tracking', style: listTileTextStyle),
          ),
          const ListTile(
            title: Text('Forecasting', style: listTileTextStyle),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchNav(),
                ),
              );
              print("moving to search");
            },
            title: const Text('Search', style: listTileTextStyle),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportsNav(),
                ),
              );
              print("moving to reports");
            },
            title: const Text('Reports', style: listTileTextStyle),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceNav(),
                ),
              );
              print("moving to maintenance");
            },
            title: const Text('Maintenance', style: listTileTextStyle),
          ),
          const ListTile(
            title: Text('Help', style: listTileTextStyle),
          ),
          const ListTile(
            title: Text('About', style: listTileTextStyle),
          ),
          ListTile(
            onTap: () {
              // Show confirmation dialog
              showLogoutConfirmationDialog(context);
            },
            title: const Text('Logout', style: listTileTextStyle),
          ),
        ],
      ),
    );
  }
  
  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
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
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}