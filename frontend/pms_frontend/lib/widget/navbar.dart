import 'package:flutter/material.dart';
import '../theme/themedata.dart';
import '../theme/colors.dart';
import 'package:hover_menu/hover_menu.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build (BuildContext context) {
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
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: ThemeColor.white2,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 100,
                          blurRadius: 0,
                          offset: const Offset(0, 0)
                        ),
                      ]
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'placeholder text', 
                              style: TextStyle(
                                fontSize: 20, 
                                color: ThemeColor.primaryColor, 
                                fontWeight: FontWeight.bold,)
                                ),
                              Padding(padding: EdgeInsets.fromLTRB(0, 0, 750, 0)),
                              HoverMenu(title: 
                              Text('placeholder text'),
                              items:[
                                ListTile(
                                  title: Text('Item1'),
                                ),
                                ListTile(
                                  title: Text('Item2')
                                )
                              ])
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }
}