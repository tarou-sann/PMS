import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import 'machinespage.dart';
import 'register.dart';
import 'repair.dart';
import 'reports.dart';
import 'search.dart';
import '../utils/responsive_helper.dart';

class MachineryManagementNav extends StatelessWidget {
  const MachineryManagementNav({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Page Header (keep original styling)
              const Text(
                "Machinery Management",
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor = (screenWidth / 1200).clamp(0.7, 0.9); // Increased scaling factor

                  // Increased card dimensions
                  double cardWidth = 380 * scaleFactor; // Increased from 320
                  double cardHeight = 380 * scaleFactor; // Increased from 320
                  double iconSize = 180 * scaleFactor; // Increased from 190
                  double fontSize = 22 * scaleFactor; // Increased from 20
                  double spacing = 35 * scaleFactor; // Increased from 30

                  // Ensure cards don't get too big or too small with updated limits
                  cardWidth = cardWidth.clamp(300.0, 380.0); // Increased from 250-320
                  cardHeight = cardHeight.clamp(300.0, 380.0); // Increased from 250-320
                  iconSize = iconSize.clamp(140.0, 180.0); // Increased from 120-160
                  fontSize = fontSize.clamp(18.0, 22.0); // Increased from 16-20
                  spacing = spacing.clamp(25.0, 35.0); // Increased from 20-30
                  
                  return Center( // Center the entire content
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        // Machines Card (exact original styling, just scaled)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MachinesNav()),
                            );
                          },
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
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.agriculture,
                                  size: iconSize,
                                  color: ThemeColor.secondaryColor,
                                ),
                                Text(
                                  "Machines",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeColor.secondaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        
                        // Repairs Card (exact original styling, just scaled)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RepairNav()),
                            );
                          },
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
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.build_outlined,
                                  size: iconSize,
                                  color: ThemeColor.secondaryColor,
                                ),
                                Text(
                                  "Repairs",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeColor.secondaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
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
}