import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../pages/register.dart';

const userName = 'test_user';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

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
                          const Text(
                            'Hello, $userName',
                            style: TextStyle(color: Colors.black, fontSize: 24),
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
                 Navigator.push(
                        context,
                         MaterialPageRoute(
                          builder: (context) => const RegisterBase(), // Fix the misplaced closing parenthesis
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
            const ListTile(
              title: Text('Logout', style: listTileTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}