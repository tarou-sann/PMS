import 'package:flutter/material.dart';
import 'package:hover_menu/hover_menu.dart';

import '../theme/colors.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String _currentText = 'Home';

  void _updateText(String newText) {
    setState(() {
      _currentText = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
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
                            HoverMenu(
                              width: 250,
                              title: const Text(
                                'Menu',
                                style: TextStyle(color: ThemeColor.primaryColor, fontSize: 24),
                              ),
                              items: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: ThemeColor.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: const Text(
                                          'Registration',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Registration'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Machine Management',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Machine Management'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Production Tracking',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Production Tracking'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Forecasting',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Forecasting'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Search',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Search'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Reports',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Reports'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Maintenance',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Maintenance'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Help',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Help'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'About',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('About'),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Logout',
                                          style: TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
                                        ),
                                        onTap: () => _updateText('Logout'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 30),
                            const Text(
                              'Hello, user1001!',
                              style: TextStyle(color: Colors.black, fontSize: 24),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
