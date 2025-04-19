import 'package:flutter/material.dart';
import 'package:hover_menu/hover_menu.dart';

import '../theme/colors.dart';

const userName = 'test_user';
const bool isAdmin = true; // For LoA

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();
  }
  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ThemeColor.white,
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded( // Ensures the container takes up available space
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: ThemeColor.white2,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 100,
                          blurRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 50, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Image.asset(
                                'lib/assets/images/Straw_innovations_small2.png',
                                width: 250,
                              ),
                              const Spacer(),
                              const Text(
                                'Hello, $userName',
                                style: TextStyle(color: Colors.black, fontSize: 24),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0 ,0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.menu,
                                    size: 30,),
                                  onPressed: _openEndDrawer, // Trigger the endDrawer
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text('Registration', style: listTileTextStyle),
            ),
            ListTile(
              title: Text('Machine Management', style: listTileTextStyle),
            ),
            ListTile(
              title: Text('Production Tracking', style: listTileTextStyle),
            ),
            ListTile(
              title: Text('Forecasting', style: listTileTextStyle),
            ),
            ListTile(
              title: Text('Search', style: listTileTextStyle),
            ),
            if (isAdmin) // Show "Maintenance" only for admin access
              ListTile(
                title: Text('Maintenance', style: listTileTextStyle),
              ),
            ListTile(
              title: Text('Help', style: listTileTextStyle),
            ),
            ListTile(
              title: Text('About', style: listTileTextStyle),
            ),
            ListTile(
              title: Text('Logout', style: listTileTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
