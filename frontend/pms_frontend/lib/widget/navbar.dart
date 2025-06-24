import 'package:flutter/material.dart';

import '../theme/colors.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  _NavbarState createState() => _NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(150);
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(3.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ThemeColor.white2,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 50, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.asset(
                  'lib/assets/images/Straw_Innovations_Horizontal.png',
                  width: 250,
                  height: 80,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    size: 30,
                    color: ThemeColor.secondaryColor,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
