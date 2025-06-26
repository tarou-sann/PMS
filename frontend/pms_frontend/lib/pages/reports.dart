import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/register.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';

import 'machinerymanagement.dart';
import 'search.dart';
import 'machinestatusreport.dart';
import 'productionreport.dart';
import 'userlogs.dart';

class ReportsNav extends StatelessWidget {
  const ReportsNav({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Page Header
              const Text(
                "Reports",
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              // Responsive card layout with size limits
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor =
                      (screenWidth / 1200).clamp(0.7, 1.0); // Conservative scaling

                  // Fixed card dimensions with scaling
                  double cardWidth = 450 * scaleFactor;
                  double cardHeight = 450 * scaleFactor;
                  double iconSize = 225 * scaleFactor;
                  double fontSize = 24 * scaleFactor;
                  double spacing = 40 * scaleFactor;

                  // Clamp to reasonable limits
                  cardWidth = cardWidth.clamp(350.0, 450.0);
                  cardHeight = cardHeight.clamp(350.0, 450.0);
                  iconSize = iconSize.clamp(180.0, 225.0);
                  fontSize = fontSize.clamp(20.0, 24.0);
                  spacing = spacing.clamp(30.0, 40.0);

                  return Center(
                    // Center the content
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildReportCard(
                          context,
                          "Machine Status Report",
                          Icons.agriculture,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MachineStatusReport())),
                        ),
                        _buildReportCard(
                          context,
                          "Production Report",
                          Icons.assessment,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProductionReport())),
                        ),
                        _buildReportCard(
                          context,
                          "User Logs",
                          Icons.recent_actors,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserLogs())),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this helper method with fixed dimensions
  Widget _buildReportCard(BuildContext context, String title, IconData icon,
      double cardWidth, double cardHeight, double iconSize, double fontSize, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: ThemeColor.white2,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: ThemeColor.secondaryColor,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: ThemeColor.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}