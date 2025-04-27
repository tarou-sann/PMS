import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../pages/register.dart';
import '../services/api_service.dart';
import '../pages/signup.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String _username = '';
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      setState(() {
        _username = userData['username'] ?? 'User';
        _isLoading = false;
      });
    } else {
      setState(() {
        _username = 'User';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _apiService.logout();
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignUpForm()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.asset(
                            'lib/assets/images/Straw_innovations_small2.png',
                            width: 250,
                          ),
                          const Spacer(),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: ThemeColor.secondaryColor,
                                )
                              : Text(
                                  'Hello, $_username',
                                  style: const TextStyle(color: Colors.black, fontSize: 24),
                                ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.menu,
                                size: 30,
                              ),
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                            ),
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
              title: const Text('Registration', style: listTileTextStyle),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterBase(),
                  ),
                );
              },
            ),
            const ListTile(
              title: Text('Machine Management', style: listTileTextStyle),
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
            ListTile(
              title: const Text('Logout', style: listTileTextStyle),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}