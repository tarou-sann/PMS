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
                      onTap: () {
                        Navigator.push(context, 
                        MaterialPageRoute(builder: 
                        (context) => const RepairOrderCreate()));
                      },
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

class RepairOrderCreate extends StatefulWidget {
  const RepairOrderCreate({super.key});

  @override
  State<RepairOrderCreate> createState() => _RepairOrderCreate();
}

class _RepairOrderCreate extends State<RepairOrderCreate> {

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: ThemeColor.secondaryColor,
    );
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
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 753,
            height: 606,
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, 
                                            MaterialPageRoute(builder: (context) => const RepairNav()));
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: ThemeColor.secondaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                      const Text(
                        "Create Repair Order",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Machine ID
                  RichText(
                    text: const TextSpan(
                      text: 'Machine ID',
                      style: labelStyle,
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: ThemeColor.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                  dropdownColor: ThemeColor.white2,
                  focusColor: ThemeColor.white2,
                  value: "test id", // Changed from "test test" to match the dropdown item value
                  items: const [
                  DropdownMenuItem(
                  value: "test id",
                  child: Text("test id"),
                   )
                 ],
                   onChanged: (value) {
                  setState(() {
            });
             },
            decoration: const InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ThemeColor.primaryColor)
            )
            ),
            ),

            const SizedBox(height: 20),

            
                  RichText(
                    text: const TextSpan(
                      text: 'Part Needed',
                      style: labelStyle,
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: ThemeColor.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                 DropdownButtonFormField<String>(
                  dropdownColor: ThemeColor.white2,
                  focusColor: ThemeColor.white2,
                  value: "test id", // Changed from "test test" to match the dropdown item value
                  items: const [
                  DropdownMenuItem(
                  value: "test id",
                  child: Text("test id"),
                   )
                 ],
                   onChanged: (value) {
                  setState(() {
            });
             },
            decoration: const InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ThemeColor.primaryColor)
            )
            ),
            ),

                  
                  const SizedBox(height: 20),

  

                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                        foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                        minimumSize: WidgetStateProperty.all(const Size(213, 65)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
