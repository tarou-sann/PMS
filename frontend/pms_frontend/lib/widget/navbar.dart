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
                              title: const Text(
                                'Menu',
                                style: TextStyle(color: ThemeColor.primaryColor, fontSize: 24),
                              ),
                              items: [
                                _buildMenuItem('Registration', 'Registration'),
                                _buildMenuItem('Machine Management', 'Machine Management'),
                                _buildMenuItem('Production Tracking', 'Production Tracking'),
                                _buildMenuItem('Forecasting', 'Forecasting'),
                                _buildMenuItem('Search', 'Search'),
                                _buildMenuItem('Reports', 'Reports'),
                                _buildMenuItem('Maintenance', 'Maintenance'),
                                _buildMenuItem('Help', 'Help'),
                                _buildMenuItem('About', 'About'),
                                _buildMenuItem('Logout', 'Logout'),
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

  Widget _buildMenuItem(String title, String text) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: Container(
        color: ThemeColor.white2,
        child: ListTile(
          mouseCursor: SystemMouseCursors.click,
          title: Text(
            title,
            style: const TextStyle(color: ThemeColor.primaryColor, fontSize: 20),
          ),
          onTap: () => _updateText(text),
        ),
      ),
    );
  }
}
