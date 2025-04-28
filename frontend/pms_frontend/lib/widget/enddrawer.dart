import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../pages/register.dart';
import '../pages/machinerymanagement.dart';
import '../pages/reports.dart';
import '../pages/search.dart';
import '../pages/maintenance.dart';

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
          const ListTile(
            title: Text('Logout', style: listTileTextStyle),
          ),
        ],
      ),
    );
  }
}