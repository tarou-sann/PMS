import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/machinerymanagement.dart';

import '../theme/colors.dart';
import '../widget/navbar.dart';
import 'register.dart';

class RepairNav extends StatelessWidget {
  const RepairNav({super.key});

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
      endDrawer: Drawer(
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
            const ListTile(
              title: Text('Search', style: listTileTextStyle),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MachineryManagementNav()));
                },
                icon: const Icon(Icons.arrow_back),
                color: ThemeColor.secondaryColor,
                iconSize: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 450,
                        height: 450,
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
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handyman_outlined,
                              weight: 200,
                              size: 225,
                              color: ThemeColor.secondaryColor,
                            ),
                            Text(
                              "Repair Status",
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 450,
                        height: 450,
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
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              weight: 22,
                              size: 225,
                              color: ThemeColor.secondaryColor,
                            ),
                            Text(
                              "Create Repair Order",
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
