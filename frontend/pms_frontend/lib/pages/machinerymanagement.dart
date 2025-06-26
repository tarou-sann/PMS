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
              
              // Responsive scaling for the cards while maintaining original proportions
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate scale factor but with better limits (like registration page)
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor = (screenWidth / 1200).clamp(0.7, 1.0); // More conservative scaling
                  
                  // Fixed card dimensions with scaling (matching registration page style)
                  double cardWidth = 450 * scaleFactor;
                  double cardHeight = 450 * scaleFactor;
                  double iconSize = 225 * scaleFactor;
                  double fontSize = 24 * scaleFactor;
                  double spacing = 40 * scaleFactor;
                  
                  // Ensure cards don't get too big or too small
                  cardWidth = cardWidth.clamp(350.0, 450.0);
                  cardHeight = cardHeight.clamp(350.0, 450.0);
                  iconSize = iconSize.clamp(180.0, 225.0);
                  fontSize = fontSize.clamp(20.0, 24.0);
                  spacing = spacing.clamp(30.0, 40.0);
                  
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